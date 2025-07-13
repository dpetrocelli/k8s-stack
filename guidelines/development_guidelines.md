# Development Guidelines

## Overview

This document outlines the development standards and best practices for the GenAI K8s Stack project.

## Pre-commit Hooks Setup

### Installation

```bash
# Install pre-commit
pip install pre-commit

# Install the git hook scripts
pre-commit install

# Run hooks on all files (optional)
pre-commit run --all-files
```

### Manual Hook Execution

```bash
# Run all hooks on staged files
pre-commit run

# Run specific hook
pre-commit run shellcheck

# Update hooks to latest versions
pre-commit autoupdate
```

## Code Standards

### Shell Scripts

- **Shebang**: Always start with `#!/bin/bash`
- **Error handling**: Use `set -e` for strict error handling
- **Variables**: Quote variables: `"$variable"`
- **Functions**: Use meaningful names and document complex functions
- **Comments**: Explain complex logic and command sequences

**Example:**

```bash
#!/bin/bash
set -e

# Function to check if cluster exists
check_cluster_exists() {
    local cluster_name="$1"
    if k3d cluster list | grep -q "$cluster_name"; then
        return 0
    else
        return 1
    fi
}
```

### Python Code

- **Formatting**: Use Black formatter (line length: 88)
- **Import sorting**: Use isort with Black profile
- **Linting**: Follow PEP 8 via flake8
- **Type hints**: Use type annotations where appropriate
- **Docstrings**: Follow Google or NumPy docstring conventions

**Example:**

```python
from typing import List, Optional

def process_data(items: List[str], filter_empty: bool = True) -> Optional[List[str]]:
    """Process a list of items with optional filtering.

    Args:
        items: List of string items to process
        filter_empty: Whether to remove empty strings

    Returns:
        Processed list or None if input is invalid
    """
    if not items:
        return None

    result = [item.strip() for item in items]
    if filter_empty:
        result = [item for item in result if item]

    return result
```

### Kubernetes Manifests

- **YAML formatting**: Use consistent indentation (2 spaces)
- **Resource naming**: Use kebab-case
- **Labels**: Include standard labels (app, version, component)
- **Security**: No hardcoded secrets or passwords
- **Resource limits**: Always specify resource requests and limits

**Example:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fastapi-inference
  labels:
    app: fastapi-inference
    version: v1.0.0
    component: api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: fastapi-inference
  template:
    metadata:
      labels:
        app: fastapi-inference
        version: v1.0.0
    spec:
      containers:
        - name: api
          image: fastapi-inference:latest
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
```

### Dockerfile Best Practices

- **Base images**: Use official, minimal base images
- **Multi-stage builds**: Use for production images
- **Layer optimization**: Combine RUN commands to reduce layers
- **Security**: Run as non-root user
- **Health checks**: Include HEALTHCHECK instructions
- **Build args**: Use for configurable builds

**Example:**

```dockerfile
# Multi-stage build
FROM python:3.11-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

FROM python:3.11-slim
RUN groupadd -r appuser && useradd -r -g appuser appuser
WORKDIR /app
COPY --from=builder /root/.local /home/appuser/.local
COPY --chown=appuser:appuser . .
USER appuser
ENV PATH=/home/appuser/.local/bin:$PATH
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1
EXPOSE 8000
CMD ["python", "app.py"]
```

## Git Workflow

### Branch Naming

- **Feature branches**: `feature/description`
- **Bug fixes**: `fix/description`
- **Hotfixes**: `hotfix/description`
- **Infrastructure**: `infra/description`

### Commit Messages

Follow conventional commits format:

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `ci`: CI/CD changes

**Examples:**

```
feat(api): add health check endpoint
fix(deployment): resolve memory leak in worker pods
docs(readme): update installation instructions
chore(deps): bump istio version to 1.26.2
```

### Pull Request Guidelines

1. **Title**: Clear, descriptive title
2. **Description**: Explain what and why
3. **Testing**: Include test results
4. **Screenshots**: For UI changes
5. **Breaking changes**: Clearly marked
6. **Reviewers**: Assign appropriate reviewers

## Testing Standards

### Unit Tests

- **Coverage**: Minimum 80% code coverage
- **Naming**: Descriptive test names
- **Structure**: Arrange-Act-Assert pattern
- **Mocking**: Mock external dependencies

### Integration Tests

- **Environment**: Use test clusters
- **Cleanup**: Always clean up resources
- **Isolation**: Tests should be independent
- **Data**: Use test data, not production data

### End-to-End Tests

- **Scenarios**: Cover critical user journeys
- **Automation**: Automated in CI/CD pipeline
- **Monitoring**: Include health checks
- **Documentation**: Clear test scenarios

## Security Guidelines

### Secrets Management

- **No hardcoded secrets**: Use Kubernetes secrets or external secret managers
- **Environment variables**: For non-sensitive configuration
- **Encryption**: Encrypt secrets at rest
- **Rotation**: Regular secret rotation policy

### Container Security

- **Vulnerability scanning**: Scan images before deployment
- **Minimal images**: Use distroless or minimal base images
- **Non-root users**: Run containers as non-root
- **Read-only filesystems**: When possible

### Network Security

- **Network policies**: Implement Kubernetes network policies
- **TLS**: Use TLS for all communications
- **Service mesh**: Leverage Istio for secure communication
- **Ingress**: Secure ingress controllers

## Documentation Standards

### Code Documentation

- **README files**: In each major directory
- **Inline comments**: For complex logic
- **API documentation**: For all APIs
- **Architecture diagrams**: For system design

### Operational Documentation

- **Runbooks**: For common operations
- **Troubleshooting guides**: For common issues
- **Deployment guides**: Step-by-step instructions
- **Monitoring guides**: How to monitor and alert

## Performance Guidelines

### Resource Management

- **Requests and limits**: Always specify
- **HPA**: Use Horizontal Pod Autoscaler
- **VPA**: Consider Vertical Pod Autoscaler
- **Resource monitoring**: Monitor resource usage

### Optimization

- **Image size**: Optimize container image sizes
- **Startup time**: Minimize application startup time
- **Memory usage**: Monitor and optimize memory usage
- **CPU usage**: Profile and optimize CPU usage

## Monitoring and Observability

### Logging

- **Structured logging**: Use JSON format
- **Log levels**: Appropriate log levels
- **Correlation IDs**: For request tracing
- **No sensitive data**: In logs

### Metrics

- **Business metrics**: Track business KPIs
- **Technical metrics**: Infrastructure metrics
- **Custom metrics**: Application-specific metrics
- **Alerting**: Set up meaningful alerts

### Tracing

- **Distributed tracing**: Use Jaeger/Zipkin
- **Span naming**: Meaningful span names
- **Error tracking**: Capture and track errors
- **Performance monitoring**: Track response times
