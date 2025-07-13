# Istio Commands Reference

## 🔍 **Essential Istio Health Check Commands**

### **Quick Status Checks**

```bash
# Check Istio version
istioctl version

# Check all Istio pods
kubectl get pods -n istio-system

# Check Istio services
kubectl get svc -n istio-system

# Check proxy status across all namespaces
istioctl proxy-status
```

### **Control Plane Health**

```bash
# Check istiod logs
kubectl logs -n istio-system deployment/istiod

# Check istiod configuration
kubectl get cm istio -n istio-system -o yaml

# Analyze configuration issues
istioctl analyze
```

### **Multicluster Setup Verification**

```bash
# Check multicluster secrets
kubectl get secrets -n istio-system | grep istio-remote-secret

# Check network configuration
kubectl get namespace istio-system -o jsonpath='{.metadata.labels.topology\.istio\.io/network}'

# Check cross-cluster endpoints
kubectl get endpoints -n istio-system
```

### **Gateway and Traffic Management**

```bash
# Check gateways
kubectl get gateways -A

# Check virtual services
kubectl get virtualservices -A

# Check destination rules
kubectl get destinationrules -A

# Check service entries
kubectl get serviceentries -A
```

### **Troubleshooting Commands**

```bash
# Check proxy configuration for a pod
istioctl proxy-config cluster <pod-name> -n <namespace>

# Get proxy configuration dump
istioctl proxy-config dump <pod-name> -n <namespace>

# Check certificate configuration
istioctl proxy-config secret <pod-name> -n <namespace>

# Validate configuration
istioctl validate -f <config-file.yaml>
```

### **Observability and Debugging**

```bash
# Open Kiali dashboard
istioctl dashboard kiali

# Open Jaeger dashboard
istioctl dashboard jaeger

# Open Grafana dashboard
istioctl dashboard grafana

# Open Prometheus dashboard
istioctl dashboard prometheus

# Check envoy access logs
kubectl logs <pod-name> -c istio-proxy
```

### **Cluster-Specific Commands**

#### **For Cluster A (agent-orchestrator)**

```bash
kubectl config use-context cluster-a
kubectl get pods -n istio-system
kubectl get svc istio-ingressgateway -n istio-system
```

#### **For Cluster B (ollama-runner)**

```bash
kubectl config use-context cluster-b
kubectl get pods -n istio-system
kubectl get svc istio-ingressgateway -n istio-system
```

### **Performance and Monitoring**

```bash
# Check resource usage
kubectl top pods -n istio-system

# Check events
kubectl get events -n istio-system --sort-by='.lastTimestamp'

# Check node status
kubectl get nodes

# Check ingress gateway external IPs
kubectl get svc istio-ingressgateway -n istio-system -o wide
```

### **Service Mesh Verification**

```bash
# Check if a namespace has Istio injection enabled
kubectl get namespace <namespace> -o jsonpath='{.metadata.labels.istio-injection}'

# Enable Istio injection for a namespace
kubectl label namespace <namespace> istio-injection=enabled

# Check which pods have Istio sidecars
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].name}{"\n"}{end}'
```

## 🚀 **Quick Health Check Script**

Run our comprehensive health check:

```bash
./check-istio.sh
```

This script checks:

- ✅ Istio installation status
- ✅ Control plane health
- ✅ Gateway status
- ✅ Multicluster configuration
- ✅ Cross-cluster connectivity
- ✅ Proxy status

## 🔧 **Common Issues & Solutions**

### **Issue: Pods not starting**

```bash
kubectl describe pod <pod-name> -n istio-system
kubectl logs <pod-name> -n istio-system
```

### **Issue: Gateway not accessible**

```bash
kubectl get svc istio-ingressgateway -n istio-system
kubectl describe svc istio-ingressgateway -n istio-system
```

### **Issue: Cross-cluster communication not working**

```bash
kubectl get secrets -n istio-system | grep istio-remote-secret
istioctl proxy-status
```

### **Issue: Configuration not applied**

```bash
istioctl analyze
kubectl get events -n istio-system
```

## 📊 **Access Points**

- **Cluster A Gateway**: <http://localhost:8080>
- **Cluster B Gateway**: <http://localhost:9080>
- **Kiali Dashboard**: `istioctl dashboard kiali`
- **Grafana Dashboard**: `istioctl dashboard grafana`

## 📚 **Useful Resources**

- [Istio Documentation](https://istio.io/latest/docs/)
- [Istio Troubleshooting](https://istio.io/latest/docs/ops/common-problems/)
- [Multicluster Setup](https://istio.io/latest/docs/setup/install/multicluster/)
- [Traffic Management](https://istio.io/latest/docs/concepts/traffic-management/)
