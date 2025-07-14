#!/bin/bash
set -e

echo "🚀 Setting up GenAI K8s Stack with k3d"

# Check prerequisites
echo "📋 Checking prerequisites..."
command -v docker >/dev/null 2>&1 || { echo "❌ Docker is required but not running"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed"; exit 1; }

# Install k3d if not present
if ! command -v k3d &> /dev/null; then
    echo "📦 Installing k3d..."
    # For macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install k3d
        else
            curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
        fi
    else
        curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    fi
fi

echo "✅ Prerequisites check completed"

# Check if cluster A exists, create if not
if k3d cluster list | grep -q "cluster-a"; then
    echo "ℹ️  Cluster A already exists, skipping creation..."
else
    echo "🏗️  Creating Cluster A (agent-orchestrator)..."
    k3d cluster create cluster-a \
        --api-port 6443 \
        --port "8080:80@loadbalancer" \
        --port "8443:443@loadbalancer" \
        --agents 2 \
        --k3s-arg "--disable=traefik@server:*" \
        --wait
fi

# Check if cluster B exists, create if not
if k3d cluster list | grep -q "cluster-b"; then
    echo "ℹ️  Cluster B already exists, skipping creation..."
else
    echo "🏗️  Creating Cluster B (ollama-runner)..."
    k3d cluster create cluster-b \
        --api-port 6444 \
        --port "9080:80@loadbalancer" \
        --port "9443:443@loadbalancer" \
        --agents 2 \
        --k3s-arg "--disable=traefik@server:*" \
        --wait
fi

echo "📋 Listing clusters:"
k3d cluster list

echo "🎯 Setting up kubectl contexts..."
# Check if contexts need to be renamed by looking specifically at the NAME column
if kubectl config get-contexts -o name | grep -q "^k3d-cluster-a$"; then
    kubectl config rename-context k3d-cluster-a cluster-a
    echo "✅ Renamed k3d-cluster-a to cluster-a"
else
    echo "ℹ️  Context cluster-a already exists"
fi

if kubectl config get-contexts -o name | grep -q "^k3d-cluster-b$"; then
    kubectl config rename-context k3d-cluster-b cluster-b
    echo "✅ Renamed k3d-cluster-b to cluster-b"
else
    echo "ℹ️  Context cluster-b already exists"
fi

echo "✅ Multi-cluster setup completed!"
echo "🔍 Use 'kubectl config get-contexts' to see available contexts"
echo "🔄 Switch contexts with 'kubectl config use-context cluster-a' or 'kubectl config use-context cluster-b'"
echo ""
echo "📊 Cluster A (agent-orchestrator): http://localhost:8080"
echo "🤖 Cluster B (ollama-runner): http://localhost:9080"
