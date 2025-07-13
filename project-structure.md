# GenAI K8s Stack - Project Structure

```
k8s-stack/
├── setup.sh                    # k3d cluster setup script
├── clusters/
│   ├── cluster-a/              # Agent orchestrator cluster
│   │   ├── apps/
│   │   │   ├── agent-orchestrator/
│   │   │   ├── n8n/
│   │   │   └── grafana-stack/
│   │   └── infrastructure/
│   │       ├── istio/
│   │       ├── argocd/
│   │       └── monitoring/
│   └── cluster-b/              # Ollama runner cluster
│       ├── apps/
│       │   ├── ollama-runner/
│       │   ├── vector-db/
│       │   └── rag-api/
│       └── infrastructure/
├── apps/
│   ├── fastapi-inference/      # FastAPI with HuggingFace/Ollama
│   ├── agent-orchestrator/     # CrewAI + LangGraph
│   ├── rag-api/               # RAG with Qdrant/Chroma
│   ├── vector-db/             # Vector database
│   └── n8n-workflows/         # Automation workflows
├── helm/
│   ├── charts/                # Custom Helm charts
│   └── values/                # Environment-specific values
├── ci-cd/
│   ├── github-actions/        # CI/CD workflows
│   ├── argocd/               # GitOps configurations
│   └── prompt-validation/     # Bedrock prompt validation
├── monitoring/
│   ├── prometheus/
│   ├── grafana/
│   ├── loki/
│   └── jaeger/
└── docs/
    ├── architecture.md
    ├── deployment.md
    └── troubleshooting.md
```

## Cluster Distribution

### Cluster A (localhost:8080)

- **agent-orchestrator**: CrewAI + LangGraph agents
- **n8n**: Workflow automation and notifications
- **grafana-stack**: Monitoring dashboards and alerting

### Cluster B (localhost:9080)

- **ollama-runner**: Local LLM inference
- **vector-db**: Qdrant/Chroma for RAG
- **rag-api**: Retrieval-Augmented Generation API

## Cross-Cluster Communication

- Istio service mesh for routing and observability
- TLS termination and JWT validation
- Fallback routing (Cluster A → Cluster B → Bedrock)
