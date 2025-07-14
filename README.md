# GenAI K8s Stack

A comprehensive Kubernetes-based infrastructure stack for Generative AI
applications, featuring multi-cluster deployment, service mesh architecture,
and integrated monitoring.

## 🚀 Quick Start

### Prerequisites

- Docker Desktop
- kubectl
- k3d
- Python 3.9+
- Git

### Setup Development Environment

1. **Clone the repository:**

   ```bash
   git clone https://github.com/dpetrocelli/k8s-stack.git
   cd k8s-stack
   ```

2. **Install pre-commit hooks (recommended):**

   ```bash
   pip install pre-commit
   pre-commit install
   ```

3. **Deploy the full stack:**

   ```bash
   ./deploy.sh
   ```

This will create two k3d clusters with Istio service mesh:

- **Cluster A (agent-orchestrator)**: <http://localhost:8080>
- **Cluster B (ollama-runner)**: <http://localhost:9080>

## 📋 Architecture

### Multi-Cluster Design

```text
┌─────────────────────┐     ┌─────────────────────┐
│    Cluster A        │     │    Cluster B        │
│  (Agent Orchestrator)│◄────┤  (Ollama Runner)    │
│                     │     │                     │
│  • n8n workflows   │     │  • Vector DB        │
│  • Agent API        │     │  • RAG API          │
│  • Grafana Stack    │     │  • Ollama Models    │
│  • ArgoCD           │     │                     │
└─────────────────────┘     └─────────────────────┘
           │                           │
           └─────── Istio Mesh ────────┘
```

### Components

#### Cluster A - Agent Orchestrator

- **n8n**: Workflow automation platform
- **Agent Orchestrator**: AI agent coordination
- **Grafana Stack**: Monitoring and observability
- **ArgoCD**: GitOps deployment management

#### Cluster B - AI Runtime

- **Ollama**: Local LLM serving
- **Vector Database**: Embeddings storage
- **RAG API**: Retrieval-augmented generation
- **FastAPI**: Inference services

## 🛠️ Development Guidelines

### Code Quality & Pre-commit Hooks

This project uses pre-commit hooks to maintain code quality and security:

```bash
# Install and setup
pip install pre-commit
pre-commit install

# Run manually
pre-commit run --all-files
```

**Enabled Checks:**

- 🐚 **Shell scripts**: ShellCheck linting
- 🐍 **Python**: Black formatting, isort, flake8
- 🐳 **Docker**: Hadolint best practices
- ☸️ **Kubernetes**: YAML validation, secret scanning
- 🔒 **Security**: Secret detection, private key scanning
- 📝 **Documentation**: Markdown linting

See [Pre-commit Setup Guide](docs/guidelines/precommit_setup.md) for detailed configuration.

### Project Guidelines

- [Development Guidelines](docs/guidelines/development_guidelines.md)
- [Contributing Guide](docs/guidelines/contributing.md)
- [Security Guidelines](docs/guidelines/security_guidelines.md)
- [Python Guidelines](docs/guidelines/python_guidelines.md)
- [AWS Guidelines](docs/guidelines/aws_guidelines.md)

## 📁 Project Structure

```text
k8s-stack/
├── 🚀 deploy.sh                    # Single-command entry point
├── 🏗️ bootstrap_cluster/           # Cluster creation & setup
│   └── setup.sh                   # k3d cluster creation script
├── 🕸️ istio/                       # Service mesh components
│   ├── install-istio.sh           # Istio installation script
│   ├── check-istio.sh             # Health check & verification
│   └── istio-commands-reference.md # Command reference guide
├── 🤖 automation/                  # Deployment automation
│   └── deploy-full-stack.sh       # Complete stack deployment
├── 📚 docs/                        # Documentation
│   ├── project-structure.md       # This structure guide
│   └── guidelines/                # Development guidelines
├── 🐳 apps/                        # Application components
│   ├── fastapi-inference/         # FastAPI inference service
│   ├── agent-orchestrator/        # AI agent coordination
│   ├── n8n-workflows/             # Workflow definitions
│   ├── rag-api/                   # RAG implementation
│   └── vector-db/                 # Vector database config
├── ⎈ helm/                         # Helm charts
│   ├── charts/                    # Application charts
│   └── values/                    # Environment values
├── 🔧 scripts/                     # Utility scripts
│   ├── check-dockerfile.sh        # Dockerfile validation
│   └── check-k8s-secrets.sh      # K8s secrets security
└── 📊 monitoring/                  # Observability stack
    ├── grafana/                   # Dashboards and config
    ├── jaeger/                    # Distributed tracing
    ├── loki/                      # Log aggregation
    └── prometheus/                # Metrics collection
```

### 🎯 **Folder-Specific Usage**

Each folder is designed for specific use cases and can be used independently:

| Folder | Use Case | Commands |
|--------|----------|----------|
| **🚀 Root** | Complete automation | `./deploy.sh` |
| **🏗️ bootstrap_cluster** | Just cluster setup | `./bootstrap_cluster/setup.sh` |
| **🕸️ istio** | Service mesh only | `./istio/install-istio.sh`, `./istio/check-istio.sh` |
| **🤖 automation** | Full stack orchestration | `cd automation && ./deploy-full-stack.sh` |
| **🐳 apps** | Application development | `docker build`, `kubectl apply` |
| **⎈ helm** | Package management | `helm install`, `helm upgrade` |
| **🔧 scripts** | Utility operations | `./scripts/check-*.sh` |
| **📚 docs** | Documentation reference | Markdown files and guides |

### 📋 **Configuration Patterns**

**Development Workflow:**
```bash
# Quick iteration
./bootstrap_cluster/setup.sh    # Create clusters
./istio/install-istio.sh        # Add service mesh
helm install app ./helm/charts/fastapi-inference/
```

**Production Deployment:**
```bash
# Complete automation
./deploy.sh                     # Everything automated
./istio/check-istio.sh         # Verify health
```

**Troubleshooting:**
```bash
# Component-specific debugging
./istio/check-istio.sh         # Service mesh health
./scripts/check-k8s-secrets.sh # Security validation
kubectl get pods -A            # Overall status
```

## 🔧 Usage

### Cluster Management

```bash
# Complete setup (recommended)
./deploy.sh

# Individual components
./bootstrap_cluster/setup.sh        # Just clusters
./istio/install-istio.sh            # Just Istio
./istio/check-istio.sh              # Verify health

# Check cluster status
kubectl config get-contexts
k3d cluster list

# Switch contexts
kubectl config use-context cluster-a
kubectl config use-context cluster-b
```

### Application Deployment

```bash
# Deploy with Helm
helm install fastapi-inference helm/charts/fastapi-inference/ \
  --values helm/values/development.yaml

# Deploy with ArgoCD
kubectl apply -f clusters/cluster-a/apps/
```

### Monitoring & Observability

```bash
# Access Grafana (after deployment)
kubectl port-forward -n monitoring svc/grafana 3000:80

# Access Jaeger
kubectl port-forward -n istio-system svc/jaeger 16686:16686

# View application logs
kubectl logs -f deployment/fastapi-inference
```

## 🔐 Security

### Best Practices Implemented

- **Container Security**: Non-root users, minimal base images
- **Network Security**: Istio mTLS, network policies
- **Secrets Management**: External secrets, no hardcoded credentials
- **RBAC**: Role-based access control
- **Security Scanning**: Automated vulnerability scanning

### Secret Management

```bash
# Never commit secrets - use external secret management
kubectl create secret generic api-keys \
  --from-literal=openai-key="your-key-here"

# Use sealed secrets for GitOps
kubeseal --format yaml < secret.yaml > sealed-secret.yaml
```

## 📊 Monitoring

### Metrics & Alerting

- **Prometheus**: Metrics collection
- **Grafana**: Visualization and dashboards
- **AlertManager**: Alert routing and management

### Logging

- **Loki**: Log aggregation
- **Fluent Bit**: Log forwarding
- **Grafana**: Log exploration

### Tracing

- **Jaeger**: Distributed tracing
- **Istio**: Service mesh observability

## 🚀 Deployment

### Local Development

```bash
# Single command setup
./deploy.sh

# Access services
echo "Cluster A: http://localhost:8080"
echo "Cluster B: http://localhost:9080"

# Verify installation
./istio/check-istio.sh
```

### Production Deployment

```bash
# Use production values
helm install app helm/charts/app/ \
  --values helm/values/production.yaml \
  --namespace production

# GitOps with ArgoCD
kubectl apply -f clusters/production/
```

## 🧪 Testing

```bash
# Run unit tests
pytest tests/unit/

# Run integration tests
pytest tests/integration/

# Run end-to-end tests
./tests/e2e/full-stack-test.sh
```

## 🤝 Contributing

We welcome contributions! Please see our
[Contributing Guide](guidelines/contributing.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Ensure pre-commit hooks pass
5. Submit a pull request

### Code Review Process

- All changes require review
- Automated checks must pass
- Security review for sensitive changes

## 📚 Documentation

- **Architecture**: [docs/architecture.md](docs/architecture.md)
- **API Reference**: [docs/api.md](docs/api.md)
- **Deployment Guide**: [docs/deployment.md](docs/deployment.md)
- **Troubleshooting**:
  [docs/troubleshooting.md](docs/troubleshooting.md)

## 🆘 Support

### Getting Help

1. Check the [documentation](docs/)
2. Search [existing issues](https://github.com/dpetrocelli/k8s-stack/issues)
3. Create a [new issue](https://github.com/dpetrocelli/k8s-stack/issues/new)

### Community

- **Issues**: Bug reports and feature requests
- **Discussions**: General questions and ideas
- **Wiki**: Community-maintained documentation

## 📄 License

This project is licensed under the MIT License - see the
[LICENSE](LICENSE) file for details.

## 🏆 Acknowledgments

- **Istio** for service mesh capabilities
- **k3d** for lightweight Kubernetes development
- **Helm** for package management
- **ArgoCD** for GitOps workflows

---

## Made with ❤️ for the AI community
