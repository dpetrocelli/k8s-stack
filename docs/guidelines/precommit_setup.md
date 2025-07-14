# Pre-commit Setup Guide

This guide explains how to set up and use the pre-commit framework in the GenAI K8s Stack project.

## What is Pre-commit?

Pre-commit is a framework for managing and maintaining multi-language pre-commit hooks. It ensures code quality, security, and consistency before code is committed to the repository.

## Installation

### 1. Install Pre-commit

```bash
pip install pre-commit
```

### 2. Install Git Hooks

```bash
# Run this in the project root directory
pre-commit install
```

### 3. (Optional) Install commit-msg hook

```bash
pre-commit install --hook-type commit-msg
```

## Configuration

The pre-commit configuration is defined in `.pre-commit-config.yaml` and includes:

### Code Quality Checks

- **Trailing whitespace removal**
- **End-of-file fixing**
- **YAML/JSON validation**
- **Merge conflict detection**
- **Large file detection** (>10MB)

### Language-Specific Checks

#### Shell Scripts

- **ShellCheck**: Linting for bash/shell scripts
- **Executable verification**: Ensures scripts have proper shebangs

#### Python Code

- **Black**: Code formatting (line length: 88)
- **isort**: Import sorting
- **flake8**: Linting and style checking

#### Kubernetes & Docker

- **Helm linting**: Chart validation
- **Dockerfile linting**: Best practices checking
- **K8s secrets scanning**: Prevents hardcoded secrets

### Security Checks

- **Secret detection**: Scans for hardcoded secrets and API keys
- **Private key detection**: Prevents committing private keys
- **Custom security scripts**: Project-specific security checks

### Documentation

- **Markdown linting**: Ensures consistent documentation formatting
- **YAML formatting**: Consistent YAML structure

## Usage

### Automatic Execution

Pre-commit hooks run automatically when you commit:

```bash
git add .
git commit -m "your commit message"
# Hooks will run automatically
```

### Manual Execution

```bash
# Run all hooks on staged files
pre-commit run

# Run all hooks on all files
pre-commit run --all-files

# Run specific hook
pre-commit run black
pre-commit run shellcheck
pre-commit run detect-secrets

# Run hooks on specific files
pre-commit run --files path/to/file1.py path/to/file2.sh
```

### Skipping Hooks

```bash
# Skip all hooks for emergency commits
git commit -m "emergency fix" --no-verify

# Skip specific hooks
SKIP=flake8,black git commit -m "commit message"
```

## Available Hooks

### General Hooks

| Hook                      | Description                    | Trigger               |
| ------------------------- | ------------------------------ | --------------------- |
| `trailing-whitespace`     | Removes trailing whitespace    | All files             |
| `end-of-file-fixer`       | Ensures files end with newline | All files             |
| `check-yaml`              | Validates YAML syntax          | `.yaml`, `.yml` files |
| `check-json`              | Validates JSON syntax          | `.json` files         |
| `check-merge-conflict`    | Detects merge conflict markers | All files             |
| `check-added-large-files` | Prevents large files (>10MB)   | All files             |
| `detect-private-key`      | Detects private keys           | All files             |

### Language-Specific Hooks

| Hook              | Description            | Trigger              |
| ----------------- | ---------------------- | -------------------- |
| `shellcheck`      | Shell script linting   | `.sh`, `.bash` files |
| `black`           | Python code formatting | `.py` files          |
| `isort`           | Python import sorting  | `.py` files          |
| `flake8`          | Python linting         | `.py` files          |
| `helmlint`        | Helm chart validation  | Helm charts          |
| `hadolint-docker` | Dockerfile linting     | `Dockerfile*`        |
| `markdownlint`    | Markdown linting       | `.md` files          |

### Custom Security Hooks

| Hook                        | Description                      | Trigger               |
| --------------------------- | -------------------------------- | --------------------- |
| `kubernetes-secrets-check`  | Scans K8s manifests for secrets  | `.yaml`, `.yml` files |
| `dockerfile-best-practices` | Checks Dockerfile best practices | `Dockerfile*`         |
| `detect-secrets`            | Comprehensive secret detection   | All files             |

## Troubleshooting

### Common Issues

#### 1. Hook Installation Fails

```bash
# Update pre-commit
pip install --upgrade pre-commit

# Reinstall hooks
pre-commit uninstall
pre-commit install
```

#### 2. Hook Execution Fails

```bash
# Update hook repositories
pre-commit autoupdate

# Clear cache and reinstall
pre-commit clean
pre-commit install --install-hooks
```

#### 3. False Positives in Secret Detection

Edit `.secrets.baseline` to add exceptions:

```bash
# Update baseline with current false positives
detect-secrets scan --update .secrets.baseline

# Review and approve false positives
detect-secrets audit .secrets.baseline
```

#### 4. Shellcheck Warnings

Common shellcheck issues and fixes:

```bash
# SC2086: Quote variables
echo $variable  # Bad
echo "$variable"  # Good

# SC2164: Use 'cd ... || exit'
cd /some/dir
cd /some/dir || exit 1  # Better

# SC1091: Sourcing files
# Add comment to disable for dynamic sources
# shellcheck disable=SC1091
source "$DYNAMIC_FILE"
```

### Hook-Specific Troubleshooting

#### Black Formatting

```bash
# Run black manually to see issues
black --check .
black --diff .

# Fix automatically
black .
```

#### Flake8 Issues

```bash
# Run flake8 manually
flake8 .

# Common fixes
# Line too long: Break into multiple lines
# Unused imports: Remove or use
# Missing docstrings: Add documentation
```

#### Helm Linting

```bash
# Run helm lint manually
helm lint helm/charts/your-chart/

# Common issues
# Missing required fields in Chart.yaml
# Invalid template syntax
# Missing values documentation
```

## Customization

### Adding New Hooks

Edit `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/new-hook-repo
    rev: v1.0.0
    hooks:
      - id: new-hook-id
        args: ["--option", "value"]
```

### Modifying Existing Hooks

```yaml
repos:
  - repo: https://github.com/psf/black
    rev: 23.12.1
    hooks:
      - id: black
        args: ["--line-length=100"] # Custom line length
```

### Creating Local Hooks

```yaml
repos:
  - repo: local
    hooks:
      - id: custom-check
        name: Custom validation
        entry: scripts/custom-check.sh
        language: script
        files: '\.py$'
```

## Integration with CI/CD

### GitHub Actions

```yaml
name: Pre-commit
on: [push, pull_request]
jobs:
  pre-commit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-python@v2
      - uses: pre-commit/action@v2.0.0
```

### GitLab CI

```yaml
pre-commit:
  stage: test
  image: python:3.11
  before_script:
    - pip install pre-commit
  script:
    - pre-commit run --all-files
```

## Best Practices

### 1. Regular Updates

```bash
# Update hook versions monthly
pre-commit autoupdate

# Test after updates
pre-commit run --all-files
```

### 2. Team Collaboration

- Ensure all team members install hooks
- Document any exceptions in project README
- Regular review of hook configurations

### 3. Performance Optimization

- Use `files` and `exclude` patterns to limit scope
- Consider using `stages` for expensive hooks
- Use local hooks sparingly

### 4. Security

- Regularly review security hook configurations
- Keep secret detection up to date
- Monitor for new security tools

## Resources

### Official Documentation

- [Pre-commit Documentation](https://pre-commit.com/)
- [Supported Hooks](https://pre-commit.com/hooks.html)

### Tool-Specific Documentation

- [Black](https://black.readthedocs.io/)
- [ShellCheck](https://www.shellcheck.net/)
- [Hadolint](https://github.com/hadolint/hadolint)
- [detect-secrets](https://github.com/Yelp/detect-secrets)

### Community Resources

- [Awesome Pre-commit Hooks](https://github.com/pre-commit/pre-commit-hooks)
- [Pre-commit Hook Examples](https://github.com/pre-commit/pre-commit.com)

## Support

If you encounter issues with pre-commit hooks:

1. **Check this documentation** for common solutions
2. **Run hooks manually** to understand the issue
3. **Check tool-specific documentation** for detailed guidance
4. **Create an issue** in the project repository with:
   - Error message
   - Steps to reproduce
   - Your environment details

---

Remember: Pre-commit hooks are there to help maintain code quality and security. When they fail, it's usually catching real issues that need attention!
