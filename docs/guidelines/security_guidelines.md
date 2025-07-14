# Security Guidelines

## Overview

This document outlines security best practices and guidelines for the GenAI K8s Stack project.

## General Security Principles

### Defense in Depth

- Multiple layers of security controls
- Network segmentation
- Access controls at multiple levels
- Monitoring and alerting

### Principle of Least Privilege

- Grant minimum necessary permissions
- Regular access reviews
- Role-based access control (RBAC)
- Service account restrictions

### Zero Trust Architecture

- Never trust, always verify
- Encrypt all communications
- Authenticate and authorize every request
- Monitor all network traffic

## Container Security

### Base Images

- **Official Images:** Use official base images from trusted registries
- **Minimal Images:** Prefer distroless or Alpine-based images
- **Regular Updates:** Keep base images updated
- **Vulnerability Scanning:** Scan images for known vulnerabilities

```dockerfile
# Good: Official minimal image
FROM python:3.11-slim

# Better: Distroless image
FROM gcr.io/distroless/python3
```

### Container Configuration

- **Non-root User:** Run containers as non-root user
- **Read-only Filesystem:** Use read-only root filesystem when possible
- **Drop Capabilities:** Remove unnecessary Linux capabilities
- **Security Context:** Configure proper security context

```yaml
apiVersion: v1
kind: Pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
  containers:
    - name: app
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop:
            - ALL
          add:
            - NET_BIND_SERVICE
```

### Image Security

- **Image Signing:** Sign container images
- **Registry Security:** Use private registries for sensitive images
- **Admission Controllers:** Implement image policy admission controllers
- **Runtime Protection:** Monitor container runtime behavior

## Kubernetes Security

### Cluster Security

- **RBAC:** Implement role-based access control
- **Network Policies:** Restrict network traffic between pods
- **Pod Security Standards:** Enforce pod security standards
- **Admission Controllers:** Use admission controllers for policy enforcement

```yaml
# Network Policy Example
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
spec:
  podSelector: {}
  policyTypes:
    - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api-ingress
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: frontend
      ports:
        - protocol: TCP
          port: 8080
```

### RBAC Configuration

```yaml
# Service Account
apiVersion: v1
kind: ServiceAccount
metadata:
  name: api-service-account
---
# Role
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: api-role
rules:
  - apiGroups: [""]
    resources: ["pods", "configmaps"]
    verbs: ["get", "list"]
---
# RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: api-role-binding
subjects:
  - kind: ServiceAccount
    name: api-service-account
roleRef:
  kind: Role
  name: api-role
  apiGroup: rbac.authorization.k8s.io
```

### Pod Security Standards

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: secure-namespace
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

## Secrets Management

### Kubernetes Secrets

- **External Secrets:** Use external secret management systems
- **Encryption at Rest:** Enable etcd encryption
- **Secret Rotation:** Implement regular secret rotation
- **Access Control:** Restrict access to secrets

```yaml
# External Secrets Operator Example
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "https://vault.example.com"
      path: "secret"
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "example-role"
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: database-credentials
spec:
  refreshInterval: 15s
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: database-secret
    creationPolicy: Owner
  data:
    - secretKey: password
      remoteRef:
        key: database
        property: password
```

### Secret Best Practices

- **Never hardcode secrets** in code or configuration files
- **Use environment variables** for configuration, not secrets
- **Implement secret scanning** in CI/CD pipelines
- **Regular rotation** of secrets and certificates
- **Audit secret access** and usage

## Network Security

### Service Mesh Security (Istio)

- **mTLS:** Enable mutual TLS for all communications
- **Authorization Policies:** Implement fine-grained access control
- **Traffic Encryption:** Encrypt all traffic between services
- **Certificate Management:** Automatic certificate rotation

```yaml
# Istio PeerAuthentication
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
---
# Istio AuthorizationPolicy
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: api-access
spec:
  selector:
    matchLabels:
      app: api
  rules:
    - from:
        - source:
            principals: ["cluster.local/ns/frontend/sa/frontend-sa"]
      to:
        - operation:
            methods: ["GET", "POST"]
            paths: ["/api/*"]
```

### Network Policies

```yaml
# Default deny all
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
---
# Allow specific communication
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-api
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: frontend
      ports:
        - protocol: TCP
          port: 8080
```

## Application Security

### Input Validation

- **Validate all inputs** from users and external systems
- **Use parameterized queries** to prevent SQL injection
- **Sanitize outputs** to prevent XSS attacks
- **Implement rate limiting** to prevent abuse

### API Security

- **Authentication:** Implement strong authentication mechanisms
- **Authorization:** Use JWT tokens or OAuth 2.0
- **API Gateway:** Use API gateway for centralized security
- **Rate Limiting:** Implement rate limiting and throttling

```python
# Example: Input validation in Python
from typing import Optional
import re

def validate_email(email: str) -> bool:
    """Validate email format."""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None

def sanitize_input(user_input: str) -> str:
    """Sanitize user input."""
    # Remove potentially dangerous characters
    sanitized = re.sub(r'[<>"\']', '', user_input)
    return sanitized.strip()
```

### Error Handling

- **Don't expose sensitive information** in error messages
- **Log security events** for monitoring
- **Implement proper error responses** for different scenarios
- **Use structured logging** for better analysis

## Data Protection

### Data Classification

- **Public:** Can be shared openly
- **Internal:** For internal use only
- **Confidential:** Sensitive business data
- **Restricted:** Highly sensitive data requiring special handling

### Data Encryption

- **Encryption at Rest:** Encrypt data stored in databases and files
- **Encryption in Transit:** Use TLS for all communications
- **Key Management:** Proper key management and rotation
- **Data Masking:** Mask sensitive data in non-production environments

### Privacy Compliance

- **GDPR Compliance:** For European users
- **Data Minimization:** Collect only necessary data
- **Right to Erasure:** Implement data deletion capabilities
- **Data Portability:** Allow users to export their data

## Monitoring and Incident Response

### Security Monitoring

- **Log Everything:** Comprehensive logging of security events
- **SIEM Integration:** Security Information and Event Management
- **Anomaly Detection:** Detect unusual patterns
- **Real-time Alerting:** Immediate notification of security events

```yaml
# Example: Security-focused logging configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: security-logging-config
data:
  fluent-bit.conf: |
    [INPUT]
        Name tail
        Path /var/log/audit/audit.log
        Tag audit.*
        Parser audit

    [FILTER]
        Name grep
        Match audit.*
        Regex log .*SYSCALL.*

    [OUTPUT]
        Name forward
        Match audit.*
        Host security-log-aggregator
        Port 24224
```

### Incident Response

1. **Detection:** Identify security incidents
2. **Analysis:** Determine scope and impact
3. **Containment:** Isolate affected systems
4. **Eradication:** Remove the threat
5. **Recovery:** Restore normal operations
6. **Lessons Learned:** Document and improve

### Security Metrics

- **Time to Detection (TTD)**
- **Time to Response (TTR)**
- **Number of security incidents**
- **Patch management compliance**
- **Vulnerability remediation time**

## Compliance and Auditing

### Audit Logging

```yaml
# Kubernetes audit policy
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  - level: Metadata
    namespaces: ["production"]
    verbs: ["create", "update", "delete"]
    resources:
      - group: ""
        resources: ["secrets", "configmaps"]
  - level: RequestResponse
    namespaces: ["production"]
    verbs: ["create", "update", "delete"]
    resources:
      - group: "apps"
        resources: ["deployments"]
```

### Compliance Frameworks

- **SOC 2:** Security controls for service organizations
- **ISO 27001:** Information security management
- **NIST Cybersecurity Framework:** Risk-based approach
- **CIS Controls:** Critical security controls

### Regular Security Assessments

- **Vulnerability Scanning:** Regular automated scans
- **Penetration Testing:** Annual penetration tests
- **Security Reviews:** Code and architecture reviews
- **Compliance Audits:** Regular compliance assessments

## DevSecOps Integration

### Shift Left Security

- **Security by Design:** Build security into development process
- **Early Testing:** Security testing in development phase
- **Developer Training:** Security awareness for developers
- **Automated Security:** Integrate security tools in CI/CD

### CI/CD Security

```yaml
# Example: Security checks in GitHub Actions
name: Security Checks
on: [push, pull_request]
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: "fs"
          scan-ref: "."
          format: "sarif"
          output: "trivy-results.sarif"

      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v1
        with:
          sarif_file: "trivy-results.sarif"

      - name: Run Bandit security linter
        run: |
          pip install bandit
          bandit -r . -f json -o bandit-report.json

      - name: Run secret detection
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: main
          head: HEAD
```

## Security Tools and Technologies

### Static Analysis

- **Bandit:** Python security linter
- **SonarQube:** Code quality and security
- **Semgrep:** Static analysis for multiple languages
- **CodeQL:** Semantic code analysis

### Dynamic Analysis

- **OWASP ZAP:** Web application security testing
- **Burp Suite:** Web vulnerability scanner
- **Nuclei:** Fast vulnerability scanner
- **Nmap:** Network discovery and security auditing

### Container Security

- **Trivy:** Vulnerability scanner for containers
- **Clair:** Static analysis of vulnerabilities
- **Falco:** Runtime security monitoring
- **Twistlock/Prisma:** Comprehensive container security

### Infrastructure Security

- **Checkov:** Static analysis for infrastructure
- **Terrascan:** Infrastructure as code scanner
- **Kube-bench:** CIS Kubernetes benchmark
- **Kube-hunter:** Kubernetes penetration testing

## Emergency Procedures

### Security Incident Response

1. **Immediate Actions:**

   - Isolate affected systems
   - Preserve evidence
   - Notify security team

2. **Investigation:**

   - Analyze logs and artifacts
   - Determine attack vector
   - Assess damage

3. **Recovery:**

   - Patch vulnerabilities
   - Restore from clean backups
   - Monitor for reinfection

4. **Post-Incident:**
   - Document lessons learned
   - Update security controls
   - Improve monitoring

### Contact Information

- **Security Team:** <security@company.com>
- **Incident Response:** <incident-response@company.com>
- **Emergency Hotline:** +1-XXX-XXX-XXXX

---

**Remember:** Security is everyone's responsibility. If you see something suspicious, report it immediately.
