#!/bin/bash
# Istio Health Check and Verification Script
# This script provides comprehensive checks for Istio service mesh

set -e

echo "🔍 Istio Service Mesh Health Check"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if istioctl is available
print_status "📦 Checking istioctl installation..."
if command -v istioctl &> /dev/null; then
    ISTIOCTL_VERSION=$(istioctl version --short 2>/dev/null || echo "Unable to get version")
    print_success "istioctl found: $ISTIOCTL_VERSION"
else
    print_warning "istioctl not found in PATH, checking for local installation..."
    # Check for local Istio installation
    found_istio=false
    for istio_dir in istio-*/bin; do
        if [ -d "$istio_dir" ]; then
            export PATH="$PWD/$istio_dir:$PATH"
            print_success "Found local istioctl, added to PATH"
            ISTIOCTL_VERSION=$(istioctl version --short 2>/dev/null || echo "Unable to get version")
            print_success "istioctl version: $ISTIOCTL_VERSION"
            found_istio=true
            break
        fi
    done

    if [ "$found_istio" = false ]; then
        print_error "No local istioctl found. Run install-istio.sh first."
        exit 1
    fi
fi

# Get list of available contexts
print_status "🌐 Available Kubernetes contexts:"
kubectl config get-contexts

# Function to check Istio on a specific cluster
check_cluster_istio() {
    local context=$1
    local cluster_name=$2

    echo
    print_status "🔍 Checking Istio on $cluster_name ($context)..."

    # Switch context
    kubectl config use-context "$context" >/dev/null 2>&1

    # Check if istio-system namespace exists
    if kubectl get namespace istio-system >/dev/null 2>&1; then
        print_success "istio-system namespace exists"
    else
        print_error "istio-system namespace not found"
        return 1
    fi

    # Check Istio control plane pods
    print_status "📊 Istio Control Plane Status:"
    kubectl get pods -n istio-system -o wide

    # Check if istiod is running
    ISTIOD_STATUS=$(kubectl get pods -n istio-system -l app=istiod --no-headers 2>/dev/null | awk '{print $3}')
    if [[ "$ISTIOD_STATUS" == "Running" ]]; then
        print_success "Istiod control plane is running"
    else
        print_error "Istiod control plane issues detected"
    fi

    # Check ingress gateway
    GATEWAY_STATUS=$(kubectl get pods -n istio-system -l app=istio-ingressgateway --no-headers 2>/dev/null | awk '{print $3}')
    if [[ "$GATEWAY_STATUS" == "Running" ]]; then
        print_success "Istio ingress gateway is running"
    else
        print_error "Istio ingress gateway issues detected"
    fi

    # Check services
    print_status "🌐 Istio Services:"
    kubectl get svc -n istio-system

    # Check Istio configuration
    print_status "⚙️  Istio Configuration:"
    kubectl get cm istio -n istio-system -o yaml | grep -A 10 -B 5 "mesh\|network" 2>/dev/null || echo "No mesh config found"

    # Check multicluster secrets
    print_status "🔗 Multicluster Secrets:"
    REMOTE_SECRETS=$(kubectl get secrets -n istio-system -o name | grep "istio-remote-secret" || echo "No remote secrets found")  # pragma: allowlist secret
    if [[ "$REMOTE_SECRETS" != "No remote secrets found" ]]; then  # pragma: allowlist secret
        kubectl get secrets -n istio-system | grep istio-remote-secret  # pragma: allowlist secret
        print_success "Multicluster secrets configured"
    else
        print_warning "No multicluster secrets found"
    fi

    # Check Istio gateways and virtual services
    print_status "🚪 Istio Gateways:"
    kubectl get gateways -A 2>/dev/null || print_warning "No gateways found"

    print_status "🔀 Virtual Services:"
    kubectl get virtualservices -A 2>/dev/null || print_warning "No virtual services found"

    # Check network labels
    print_status "🏷️  Network Labels:"
    NETWORK_LABEL=$(kubectl get namespace istio-system -o jsonpath='{.metadata.labels.topology\.istio\.io/network}' 2>/dev/null || echo "No network label")
    if [[ "$NETWORK_LABEL" != "No network label" ]]; then
        print_success "Network label: $NETWORK_LABEL"
    else
        print_warning "No network label found"
    fi
}

# Check both clusters if they exist
print_status "🔍 Checking Istio installation on all clusters..."

# Check cluster-a
if kubectl config get-contexts cluster-a >/dev/null 2>&1; then
    check_cluster_istio "cluster-a" "Cluster A (agent-orchestrator)"
else
    print_warning "cluster-a context not found"
fi

# Check cluster-b
if kubectl config get-contexts cluster-b >/dev/null 2>&1; then
    check_cluster_istio "cluster-b" "Cluster B (ollama-runner)"
else
    print_warning "cluster-b context not found"
fi

# Cross-cluster connectivity check
echo
print_status "🔗 Multicluster Connectivity Check..."

if kubectl config get-contexts cluster-a >/dev/null 2>&1 && kubectl config get-contexts cluster-b >/dev/null 2>&1; then
    print_status "Testing cross-cluster endpoint discovery..."

    # Check if clusters can see each other's endpoints
    kubectl config use-context cluster-a >/dev/null 2>&1
    CLUSTER_A_ENDPOINTS=$(kubectl get endpoints -n istio-system --no-headers | wc -l)

    kubectl config use-context cluster-b >/dev/null 2>&1
    CLUSTER_B_ENDPOINTS=$(kubectl get endpoints -n istio-system --no-headers | wc -l)

    if [[ $CLUSTER_A_ENDPOINTS -gt 0 && $CLUSTER_B_ENDPOINTS -gt 0 ]]; then
        print_success "Cross-cluster endpoint discovery working"
    else
        print_warning "Cross-cluster connectivity may have issues"
    fi
else
    print_warning "Cannot test cross-cluster connectivity - missing clusters"
fi

# Istio proxy status check
echo
print_status "🔍 Istio Proxy Status Check..."
if command -v istioctl &> /dev/null; then
    kubectl config use-context cluster-a >/dev/null 2>&1
    print_status "Cluster A proxy status:"
    istioctl proxy-status 2>/dev/null || print_warning "No proxies found or istioctl proxy-status failed"

    kubectl config use-context cluster-b >/dev/null 2>&1
    print_status "Cluster B proxy status:"
    istioctl proxy-status 2>/dev/null || print_warning "No proxies found or istioctl proxy-status failed"
fi

# Summary
echo
print_status "📋 Health Check Summary"
print_status "======================"
echo "✅ Use this script to verify Istio installation"
echo "✅ Check both individual clusters and multicluster setup"
echo "✅ Monitor proxy status and configuration"
echo
echo "🔧 Troubleshooting commands:"
echo "  istioctl analyze                    # Analyze configuration issues"
echo "  istioctl proxy-config cluster       # Check proxy configuration"
echo "  kubectl logs -n istio-system <pod>  # Check pod logs"
echo "  istioctl dashboard kiali            # Open Kiali dashboard"
echo
echo "📖 For more details, check the Istio documentation:"
echo "  https://istio.io/latest/docs/"
