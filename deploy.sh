#!/bin/bash
# Main deployment wrapper script
# This script provides a simple entry point for the entire stack deployment

set -e

echo "🚀 GenAI K8s Stack - Main Deployment"
echo "====================================="
echo ""
echo "This will deploy:"
echo "  ✅ Multi-cluster k3d setup (cluster-a, cluster-b)"
echo "  ✅ Istio service mesh with multicluster communication"
echo "  ✅ All infrastructure components"
echo ""

# Check if automation script exists
if [ ! -f "automation/deploy-full-stack.sh" ]; then
    echo "❌ Automation script not found!"
    echo "Please run this script from the project root directory."
    exit 1
fi

# Make sure automation script is executable
chmod +x automation/deploy-full-stack.sh

# Run the main deployment
cd automation
./deploy-full-stack.sh
cd ..

echo ""
echo "🎉 Deployment completed!"
echo ""
echo "📋 Next steps:"
echo "  • Check cluster status: kubectl get nodes"
echo "  • Verify Istio: ./bootstrap_cluster/check-istio.sh"
echo "  • Deploy applications: helm install ..."
echo "  • Access points:"
echo "    - Cluster A: http://localhost:8080"
echo "    - Cluster B: http://localhost:9080"
