# GenAI K8s Stack - Project Structure

## 📁 **Organized Folder Structure**

```
k8s-stack/
├── 🚀 deploy.sh                      # Main deployment entry point
├── 📋 README.md                      # Project overview
├── ⚙️  .pre-commit-config.yaml       # Quality gates configuration
├── 🔒 .secrets.baseline              # Security scanning baseline
├── 📦 .gitignore                     # Git ignore rules
│
├── 🏗️  bootstrap_cluster/            # Cluster Creation & Setup
│   └── setup.sh                     # k3d cluster creation script
│
├── 🕸️  istio/                        # Service Mesh Components
│   ├── install-istio.sh             # Istio installation script
│   ├── check-istio.sh               # Health check & verification
│   └── istio-commands-reference.md  # Command reference guide
│
├── 🤖 automation/                    # Deployment Automation
│   └── deploy-full-stack.sh         # Complete stack deployment
│
├── 📚 docs/                          # Documentation
│   ├── project-structure.md         # This file
│   ├── guidelines/                  # Development guidelines
│   │   ├── contributing.md
│   │   ├── development_guidelines.md
│   │   ├── precommit_setup.md
│   │   ├── python_guidelines.md
│   │   ├── security_guidelines.md
│   │   └── aws_guidelines.md
│   ├── PRECOMMIT_ISSUES_RESOLUTION.md
│   └── PRECOMMIT_SETUP_SUMMARY.md
│
├── 🐳 apps/                          # Application Components
│   └── fastapi-inference/           # FastAPI inference service
│       ├── app.py                   # Application code
│       ├── requirements.txt         # Python dependencies
│       ├── Dockerfile              # Container configuration
│       └── .dockerignore           # Docker ignore rules
│
├── ⎈  helm/                          # Helm Charts
│   └── charts/
│       └── fastapi-inference/       # FastAPI service chart
│           ├── Chart.yaml
│           ├── values.yaml
│           └── templates/
│               ├── _helpers.tpl
│               └── deployment.yaml
│
└── 🔧 scripts/                       # Utility Scripts
    ├── check-dockerfile.sh          # Dockerfile validation
    └── check-k8s-secrets.sh        # K8s secrets security check
```

## 🎯 **Quick Start**

### **Single Command Deployment**

```bash
./deploy.sh
```

This runs the complete automated setup:

- Creates k3d clusters (cluster-a, cluster-b)
- Installs Istio service mesh
- Configures multicluster communication
- Sets up all infrastructure

### **Individual Components**

#### **Bootstrap Clusters**

```bash
./bootstrap_cluster/setup.sh
```

#### **Install Istio**

```bash
./istio/install-istio.sh
```

#### **Verify Installation**

```bash
./istio/check-istio.sh
```

#### **Deploy Applications**

```bash
helm install fastapi-inference ./helm/charts/fastapi-inference/
```

## 📋 **Folder Purposes**

| Folder | Purpose | Key Files |
|--------|---------|-----------|
| **bootstrap_cluster** | k3d cluster creation and initial setup | `setup.sh` |
| **istio** | Service mesh installation and management | `install-istio.sh`, `check-istio.sh` |
| **automation** | Complete stack deployment automation | `deploy-full-stack.sh` |
| **apps** | Application source code and configurations | `fastapi-inference/` |
| **helm** | Kubernetes application package management | Chart templates and values |
| **docs** | Project documentation and guidelines | Development and setup guides |
| **scripts** | Utility scripts for validation and checks | Security and quality scripts |

## 🔄 **Workflow**

1. **Bootstrap**: `./deploy.sh` → Sets up entire infrastructure
2. **Verify**: `./istio/check-istio.sh` → Confirms everything is working
3. **Deploy**: Use Helm charts to deploy applications
4. **Monitor**: Use Istio dashboards and kubectl for monitoring

## 🎨 **Benefits of This Structure**

✅ **Organized**: Each component has its own dedicated folder
✅ **Modular**: Can run individual components separately
✅ **Scalable**: Easy to add new components
✅ **Maintainable**: Clear separation of concerns
✅ **Documented**: Each folder has its purpose clearly defined
✅ **Automated**: Single command deployment from root

## 🚀 **Access Points**

- **Cluster A (agent-orchestrator)**: <http://localhost:8080>
- **Cluster B (ollama-runner)**: <http://localhost:9080>
- **Kiali Dashboard**: `istioctl dashboard kiali`
- **Grafana Dashboard**: `istioctl dashboard grafana`

This structure provides a clean, professional organization that scales well as the project grows!
