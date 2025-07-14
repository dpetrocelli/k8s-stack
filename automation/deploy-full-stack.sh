#!/bin/bash
set -e

# Compatible with bash 3.x (macOS default)

echo "🚀 GenAI K8s Stack - Full Deployment"
echo "======================================"

# Step 1: Setup k3d clusters
echo ""
echo "📋 Step 1: Setting up k3d clusters..."
if [ ! -f "../bootstrap_cluster/setup.sh" ]; then
    echo "❌ setup.sh not found in bootstrap_cluster directory"
    exit 1
fi

chmod +x ../bootstrap_cluster/setup.sh
../bootstrap_cluster/setup.sh

# Step 2: Install Istio service mesh
echo ""
echo "🕸️  Step 2: Installing Istio service mesh..."

# Check if istioctl is installed
if ! command -v istioctl &> /dev/null; then
    # Check if istio is already downloaded locally
    ISTIO_DIR=$(find "$PWD/.." -maxdepth 1 -type d -name "istio-*" | head -1)
    if [ -n "$ISTIO_DIR" ] && [ -f "$ISTIO_DIR/bin/istioctl" ]; then
        echo "ℹ️  Found local Istio installation at $ISTIO_DIR, adding to PATH..."
        export PATH="$ISTIO_DIR/bin:$PATH"
    else
        echo "📦 Installing istioctl..."
        curl -L https://istio.io/downloadIstio | sh -
        ISTIO_DIR=$(find "$PWD/.." -maxdepth 1 -type d -name "istio-*" | head -1)
        export PATH="$ISTIO_DIR/bin:$PATH"
        echo "⚠️  Note: istioctl added to PATH for this session only"
        echo "   To persist, add $ISTIO_DIR/bin to your PATH"
    fi
else
    echo "ℹ️  istioctl already available in PATH"
fi

# Verify istioctl is accessible
if ! command -v istioctl &> /dev/null; then
    echo "❌ istioctl still not found in PATH"
    exit 1
fi

echo "✅ istioctl version: $(istioctl version --short)"

# Define clusters (compatible with bash 3.x)
CLUSTERS="cluster-a:agent-orchestrator cluster-b:ollama-runner"

# Install Istio on both clusters
for cluster_config in $CLUSTERS; do
    cluster=$(echo "$cluster_config" | cut -d: -f1)
    service_name=$(echo "$cluster_config" | cut -d: -f2)

    echo "🏗️  Installing Istio on $cluster ($service_name)..."

    # Switch to cluster context
    kubectl config use-context "$cluster"

    # Create istio-system namespace
    kubectl create namespace istio-system --dry-run=client -o yaml | kubectl apply -f -

    # Install Istio with cluster-specific configuration
    istioctl install --set values.global.meshID=mesh1 \
        --set values.global.network="${cluster}-network" \
        --set values.pilot.env.PILOT_ENABLE_CROSS_CLUSTER_WORKLOAD_ENTRY=true \
        --set values.gateways.istio-ingressgateway.type=LoadBalancer \
        -y

    # Label namespace for istio injection
    kubectl label namespace default istio-injection=enabled --overwrite

    echo "✅ Istio installed on $cluster"
done

# Step 3: Verify installation
echo ""
echo "🔍 Step 3: Verifying installation..."
for cluster_config in $CLUSTERS; do
    cluster=$(echo "$cluster_config" | cut -d: -f1)
    service_name=$(echo "$cluster_config" | cut -d: -f2)

    echo ""
    echo "$cluster ($service_name) Istio pods:"
    kubectl config use-context "$cluster"
    kubectl get pods -n istio-system
    echo ""
    echo "$cluster Gateway:"
    kubectl get svc -n istio-system istio-ingressgateway
done

echo ""
echo "✅ GenAI K8s Stack deployment completed!"
echo "🌐 Access points:"
echo "   Cluster A (agent-orchestrator): http://localhost:8080"
echo "   Cluster B (ollama-runner): http://localhost:9080"
echo ""
echo "📝 Next steps:"
echo "   - Deploy infrastructure components (ArgoCD, monitoring)"
echo "   - Deploy applications (FastAPI, agent-orchestrator, RAG API)"
echo "   - Configure cross-cluster communication"
