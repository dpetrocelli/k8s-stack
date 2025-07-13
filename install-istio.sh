#!/bin/bash
set -e

echo "🕸️  Installing Istio service mesh on both clusters"

# Check if istioctl is installed
if ! command -v istioctl &> /dev/null; then
    echo "📦 Installing istioctl..."
    curl -L https://istio.io/downloadIstio | sh -
    export PATH="$PWD/istio-*/bin:$PATH"
    sudo cp istio-*/bin/istioctl /usr/local/bin/
fi

echo "✅ istioctl version: $(istioctl version --short)"

# Install Istio on Cluster A
echo "🏗️  Installing Istio on Cluster A (agent-orchestrator)..."
kubectl config use-context cluster-a

# Create istio-system namespace
kubectl create namespace istio-system --dry-run=client -o yaml | kubectl apply -f -

# Install Istio with custom configuration for cluster A
istioctl install --set values.global.meshID=mesh1 \
    --set values.global.network=cluster-a-network \
    --set values.global.cluster=cluster-a \
    --set values.pilot.env.PILOT_ENABLE_CROSS_CLUSTER_WORKLOAD_ENTRY=true \
    --set values.istiodRemote.enabled=false \
    --set values.pilot.env.PILOT_ENABLE_WORKLOAD_ENTRY_AUTOREGISTRATION=true \
    --set values.gateways.istio-ingressgateway.type=LoadBalancer \
    --yes

# Label namespace for istio injection
kubectl label namespace default istio-injection=enabled --overwrite

# Install Istio on Cluster B
echo "🏗️  Installing Istio on Cluster B (ollama-runner)..."
kubectl config use-context cluster-b

# Create istio-system namespace
kubectl create namespace istio-system --dry-run=client -o yaml | kubectl apply -f -

# Install Istio with custom configuration for cluster B
istioctl install --set values.global.meshID=mesh1 \
    --set values.global.network=cluster-b-network \
    --set values.global.cluster=cluster-b \
    --set values.pilot.env.PILOT_ENABLE_CROSS_CLUSTER_WORKLOAD_ENTRY=true \
    --set values.istiodRemote.enabled=false \
    --set values.pilot.env.PILOT_ENABLE_WORKLOAD_ENTRY_AUTOREGISTRATION=true \
    --set values.gateways.istio-ingressgateway.type=LoadBalancer \
    --yes

# Label namespace for istio injection
kubectl label namespace default istio-injection=enabled --overwrite

# Create cross-cluster secrets for service discovery
echo "🔗 Setting up cross-cluster service discovery..."

# Get cluster A endpoint info
kubectl config use-context cluster-a
CLUSTER_A_SECRET=$(kubectl get secret -n istio-system -l istio/multicluster=prepare -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -z "$CLUSTER_A_SECRET" ]; then
    echo "Creating multicluster secret for cluster A..."
    kubectl create secret generic cacerts -n istio-system --dry-run=client -o yaml | kubectl apply -f -
    kubectl label secret cacerts -n istio-system istio/multicluster=prepare --overwrite
    CLUSTER_A_SECRET="cacerts"  # pragma: allowlist secret
fi

# Get cluster B endpoint info
kubectl config use-context cluster-b
CLUSTER_B_SECRET=$(kubectl get secret -n istio-system -l istio/multicluster=prepare -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -z "$CLUSTER_B_SECRET" ]; then
    echo "Creating multicluster secret for cluster B..."
    kubectl create secret generic cacerts -n istio-system --dry-run=client -o yaml | kubectl apply -f -
    kubectl label secret cacerts -n istio-system istio/multicluster=prepare --overwrite
    CLUSTER_B_SECRET="cacerts"  # pragma: allowlist secret
fi

# Verify Istio installation
echo "🔍 Verifying Istio installation..."
kubectl config use-context cluster-a
kubectl get pods -n istio-system
echo ""
echo "Cluster A Gateway:"
kubectl get svc -n istio-system istio-ingressgateway

kubectl config use-context cluster-b
kubectl get pods -n istio-system
echo ""
echo "Cluster B Gateway:"
kubectl get svc -n istio-system istio-ingressgateway

echo "✅ Istio multi-cluster setup completed!"
echo "🌐 Access gateways:"
echo "   Cluster A: http://localhost:8080"
echo "   Cluster B: http://localhost:9080"
