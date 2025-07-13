# Contributing to GenAI K8s Stack

Thank you for your interest in contributing to the GenAI K8s Stack project! This document provides guidelines for contributing to the project.

## Getting Started

### Prerequisites

- Docker Desktop
- kubectl
- k3d
- Python 3.9+
- Git
- Pre-commit hooks

### Development Environment Setup

1. **Clone the repository:**

   ```bash
   git clone https://github.com/dpetrocelli/k8s-stack.git
   cd k8s-stack
   ```

2. **Install pre-commit hooks:**

   ```bash
   pip install pre-commit
   pre-commit install
   ```

3. **Set up the development clusters:**

   ```bash
   ./setup.sh
   ```

4. **Deploy the full stack:**

   ```bash
   ./deploy-full-stack.sh
   ```

## How to Contribute

### Reporting Issues

Before creating an issue, please:

- Check if the issue already exists
- Use the issue templates
- Provide detailed information
- Include steps to reproduce

**Issue Types:**

- 🐛 **Bug Report**: Something isn't working
- 🚀 **Feature Request**: New functionality
- 📚 **Documentation**: Improvements to docs
- 🔧 **Enhancement**: Improve existing functionality
- ❓ **Question**: General questions

### Submitting Changes

1. **Fork the repository**
2. **Create a feature branch:**

   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes:**

   - Follow the coding standards
   - Add tests for new functionality
   - Update documentation
   - Ensure pre-commit hooks pass

4. **Commit your changes:**

   ```bash
   git add .
   git commit -m "feat(component): add new feature"
   ```

5. **Push to your fork:**

   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**

### Pull Request Guidelines

#### PR Title Format

Use conventional commits format:

```
type(scope): short description
```

#### PR Description Template

```markdown
## Description

Brief description of changes

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update
- [ ] Refactoring
- [ ] Performance improvement

## Testing

- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Pre-commit hooks pass

## Checklist

- [ ] Code follows project guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or clearly documented)
- [ ] Tests added/updated
- [ ] CHANGELOG updated (for significant changes)

## Screenshots (if applicable)

Add screenshots for UI changes

## Additional Notes

Any additional context or notes
```

### Code Review Process

1. **Automated Checks:** All CI checks must pass
2. **Peer Review:** At least one approval required
3. **Documentation Review:** For documentation changes
4. **Security Review:** For security-related changes

#### Review Criteria

- **Functionality:** Does it work as intended?
- **Code Quality:** Is it readable and maintainable?
- **Testing:** Are there adequate tests?
- **Documentation:** Is it properly documented?
- **Security:** Are there security implications?
- **Performance:** Any performance impact?

## Development Workflow

### Branch Strategy

- **main**: Production-ready code
- **develop**: Integration branch for features
- **feature/\***: New features
- **fix/\***: Bug fixes
- **hotfix/\***: Critical fixes for production

### Release Process

1. Create release branch from develop
2. Finalize features and fix bugs
3. Update version numbers
4. Create release notes
5. Merge to main and tag
6. Deploy to production

## Testing Guidelines

### Test Categories

#### Unit Tests

```bash
# Python tests
pytest tests/unit/

# Shell script tests
bats tests/unit/
```

#### Integration Tests

```bash
# Kubernetes integration tests
pytest tests/integration/

# Multi-cluster tests
./tests/integration/multi-cluster-test.sh
```

#### End-to-End Tests

```bash
# Full stack tests
./tests/e2e/full-stack-test.sh
```

### Test Requirements

- **Coverage:** Minimum 80% for new code
- **Performance:** No significant performance regression
- **Security:** No new security vulnerabilities
- **Compatibility:** Works across supported versions

## Documentation Guidelines

### Documentation Types

- **API Documentation:** For all APIs
- **User Guides:** How-to guides for users
- **Developer Guides:** For contributors
- **Architecture Docs:** System design and architecture
- **Runbooks:** Operational procedures

### Documentation Standards

- **Format:** Markdown for most documentation
- **Structure:** Clear headings and sections
- **Examples:** Include code examples
- **Diagrams:** Use Mermaid for diagrams
- **Links:** Keep internal links updated

### Documentation Locations

- `/docs/`: Main documentation
- `/guidelines/`: Development guidelines
- `/README.md`: Project overview
- Component READMEs: In each major directory

## Security Guidelines

### Security Considerations

- **Secrets:** Never commit secrets
- **Dependencies:** Keep dependencies updated
- **Vulnerabilities:** Run security scans
- **Access Control:** Principle of least privilege
- **Data Protection:** Protect sensitive data

### Security Review Process

1. **Automated Security Scanning**
2. **Manual Security Review**
3. **Penetration Testing** (for major changes)
4. **Security Team Approval** (if applicable)

## Community Guidelines

### Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Provide constructive feedback
- Focus on what's best for the community

### Communication Channels

- **GitHub Issues:** Bug reports and feature requests
- **GitHub Discussions:** General discussions
- **Pull Requests:** Code review and collaboration

### Recognition

Contributors are recognized through:

- Contributor list in README
- Release notes mentions
- Community shout-outs

## Getting Help

### Resources

- **Documentation:** Check `/docs/` directory
- **Guidelines:** Review development guidelines
- **Examples:** Look at existing code
- **Issues:** Search existing issues

### Support Channels

1. **Documentation:** Start with project docs
2. **GitHub Issues:** For bugs and features
3. **GitHub Discussions:** For questions
4. **Code Review:** During pull requests

## Project Structure

```
k8s-stack/
├── apps/                   # Application code
├── ci-cd/                  # CI/CD configurations
├── clusters/               # Cluster configurations
├── docs/                   # Project documentation
├── guidelines/             # Development guidelines
├── helm/                   # Helm charts
├── monitoring/             # Monitoring configurations
├── scripts/                # Utility scripts
├── tests/                  # Test suites
├── .pre-commit-config.yaml # Pre-commit configuration
├── .gitignore             # Git ignore rules
├── README.md              # Project overview
├── setup.sh               # Cluster setup script
└── deploy-full-stack.sh   # Full deployment script
```

## Release Notes

When contributing, please consider whether your changes should be mentioned in the release notes:

- **Major Features:** Always include
- **Bug Fixes:** Include if user-facing
- **Breaking Changes:** Always include with migration guide
- **Dependencies:** Include significant updates
- **Security Fixes:** Always include

## License

By contributing to this project, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for contributing to the GenAI K8s Stack project! Your contributions help make this project better for everyone.
