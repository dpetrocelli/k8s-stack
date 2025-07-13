#!/bin/bash
# check-dockerfile.sh - Check Dockerfile best practices

set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check Dockerfile best practices
check_dockerfile() {
    local file="$1"
    local issues_found=0
    local warnings_found=0

    echo "🐳 Checking $file for Dockerfile best practices..."
    echo ""

    # Check if file exists and is readable
    if [[ ! -f "$file" || ! -r "$file" ]]; then
        echo -e "${RED}❌ Cannot read file: $file${NC}"
        return 1
    fi

    # Best practices checks

    # 1. Check for specific base image version (not latest)
    if grep -q "FROM.*:latest" "$file"; then
        echo -e "${RED}❌ Using 'latest' tag for base image${NC}"
        echo -e "${YELLOW}   Recommendation: Use specific version tags for reproducible builds${NC}"
        echo -e "${BLUE}   Example: FROM python:3.11-slim instead of FROM python:latest${NC}"
        echo ""
        issues_found=$((issues_found + 1))
    fi

    # 2. Check for non-root user
    if ! grep -q "USER" "$file"; then
        echo -e "${YELLOW}⚠️  No USER instruction found${NC}"
        echo -e "${YELLOW}   Recommendation: Run container as non-root user for security${NC}"
        echo -e "${BLUE}   Example: USER 1000:1000${NC}"
        echo ""
        warnings_found=$((warnings_found + 1))
    fi

    # 3. Check for HEALTHCHECK
    if ! grep -q "HEALTHCHECK" "$file"; then
        echo -e "${YELLOW}⚠️  No HEALTHCHECK instruction found${NC}"
        echo -e "${YELLOW}   Recommendation: Add health check for better container orchestration${NC}"
        echo -e "${BLUE}   Example: HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost:8000/health${NC}"
        echo ""
        warnings_found=$((warnings_found + 1))
    fi

    # 4. Check for .dockerignore reference
    dockerfile_dir=$(dirname "$file")
    if [[ ! -f "$dockerfile_dir/.dockerignore" ]]; then
        echo -e "${YELLOW}⚠️  No .dockerignore file found${NC}"
        echo -e "${YELLOW}   Recommendation: Create .dockerignore to exclude unnecessary files${NC}"
        echo ""
        warnings_found=$((warnings_found + 1))
    fi

    # 5. Check for multiple RUN commands that could be combined
    run_count=$(grep -c "^RUN" "$file" || true)
    if [[ $run_count -gt 3 ]]; then
        echo -e "${YELLOW}⚠️  Found $run_count RUN instructions${NC}"
        echo -e "${YELLOW}   Recommendation: Combine RUN commands to reduce image layers${NC}"
        echo -e "${BLUE}   Example: RUN apt-get update && apt-get install -y package1 package2${NC}"
        echo ""
        warnings_found=$((warnings_found + 1))
    fi

    # 6. Check for package manager cache cleanup
    if grep -q "apt-get\|apk\|yum" "$file" && ! grep -q "rm -rf.*cache\|--no-cache\|apt-get clean" "$file"; then
        echo -e "${YELLOW}⚠️  Package installation without cache cleanup${NC}"
        echo -e "${YELLOW}   Recommendation: Clean package manager cache to reduce image size${NC}"
        echo -e "${BLUE}   Example: RUN apt-get update && apt-get install -y package && rm -rf /var/lib/apt/lists/*${NC}"
        echo ""
        warnings_found=$((warnings_found + 1))
    fi

    # 7. Check for hardcoded secrets or passwords
    if grep -iE "(password|secret|key|token).*=" "$file"; then
        echo -e "${RED}❌ Potential hardcoded secrets found${NC}"
        echo -e "${YELLOW}   Recommendation: Use build args or environment variables for secrets${NC}"
        echo -e "${BLUE}   Example: ARG API_KEY and ENV API_KEY=\$API_KEY${NC}"
        echo ""
        issues_found=$((issues_found + 1))
    fi

    # 8. Check for WORKDIR usage
    if ! grep -q "WORKDIR" "$file"; then
        echo -e "${YELLOW}⚠️  No WORKDIR instruction found${NC}"
        echo -e "${YELLOW}   Recommendation: Use WORKDIR to set working directory${NC}"
        echo -e "${BLUE}   Example: WORKDIR /app${NC}"
        echo ""
        warnings_found=$((warnings_found + 1))
    fi

    # 9. Check for COPY vs ADD usage
    if grep -q "^ADD" "$file" && ! grep -q "http\|ftp" "$file"; then
        echo -e "${YELLOW}⚠️  Using ADD instead of COPY${NC}"
        echo -e "${YELLOW}   Recommendation: Use COPY for local files, ADD only for URLs or tar extraction${NC}"
        echo -e "${BLUE}   Example: COPY . /app instead of ADD . /app${NC}"
        echo ""
        warnings_found=$((warnings_found + 1))
    fi

    # 10. Check for multi-stage builds for complex applications
    stage_count=$(grep -c "^FROM" "$file" || true)
    if [[ $stage_count -eq 1 ]] && grep -qE "(build|compile|npm|pip|go build)" "$file"; then
        echo -e "${YELLOW}⚠️  Consider using multi-stage build${NC}"
        echo -e "${YELLOW}   Recommendation: Use multi-stage builds to reduce final image size${NC}"
        echo -e "${BLUE}   Example: FROM node:16 AS builder ... FROM node:16-alpine AS runtime${NC}"
        echo ""
        warnings_found=$((warnings_found + 1))
    fi

    # 11. Check for specific port exposure
    if ! grep -q "EXPOSE" "$file"; then
        echo -e "${YELLOW}⚠️  No EXPOSE instruction found${NC}"
        echo -e "${YELLOW}   Recommendation: Document which ports the container listens on${NC}"
        echo -e "${BLUE}   Example: EXPOSE 8080${NC}"
        echo ""
        warnings_found=$((warnings_found + 1))
    fi

    # 12. Check for label usage
    if ! grep -q "LABEL" "$file"; then
        echo -e "${YELLOW}⚠️  No LABEL instructions found${NC}"
        echo -e "${YELLOW}   Recommendation: Add metadata labels for better container management${NC}"
        echo -e "${BLUE}   Example: LABEL version=\"1.0\" maintainer=\"team@company.com\"${NC}"
        echo ""
        warnings_found=$((warnings_found + 1))
    fi

    # 13. Security: Check for running as root explicitly
    if grep -q "USER root\|USER 0" "$file"; then
        echo -e "${RED}❌ Explicitly running as root user${NC}"
        echo -e "${YELLOW}   Recommendation: Avoid running as root for security reasons${NC}"
        echo ""
        issues_found=$((issues_found + 1))
    fi

    # 14. Check for shell form vs exec form
    if grep -qE "^(RUN|CMD|ENTRYPOINT).*\$\(" "$file"; then
        echo -e "${YELLOW}⚠️  Using shell form for instructions${NC}"
        echo -e "${YELLOW}   Recommendation: Consider exec form for better signal handling${NC}"
        echo -e "${BLUE}   Example: CMD [\"python\", \"app.py\"] instead of CMD python app.py${NC}"
        echo ""
        warnings_found=$((warnings_found + 1))
    fi

    # Good practices found
    echo -e "${GREEN}✅ Good practices found:${NC}"

    if grep -q "FROM.*alpine\|FROM.*slim\|FROM.*distroless" "$file"; then
        echo "   • Using minimal base image"
    fi

    if [[ $stage_count -gt 1 ]]; then
        echo "   • Using multi-stage build"
    fi

    if grep -q "USER [1-9]" "$file"; then
        echo "   • Running as non-root user"
    fi

    if grep -q "HEALTHCHECK" "$file"; then
        echo "   • Health check configured"
    fi

    if grep -q "COPY.*chown" "$file"; then
        echo "   • Using COPY with chown"
    fi

    echo ""
    echo "📊 Summary for $file:"
    echo "   Critical issues: $issues_found"
    echo "   Warnings: $warnings_found"
    echo ""

    return $issues_found
}

# Function to create sample .dockerignore if it doesn't exist
create_sample_dockerignore() {
    local dir="$1"
    local dockerignore_file="$dir/.dockerignore"

    if [[ ! -f "$dockerignore_file" ]]; then
        cat > "$dockerignore_file" << 'EOF'
# Git
.git
.gitignore

# CI/CD
.github
.gitlab-ci.yml
Jenkinsfile

# Documentation
README.md
docs/
*.md

# IDE
.vscode
.idea
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Dependencies (for multi-stage builds, copy these in specific stages)
node_modules/
__pycache__/
*.pyc
.pytest_cache/

# Test files
tests/
*_test.go
*_test.py
test_*.py

# Development files
.env.local
.env.development
docker-compose.dev.yml
EOF
        echo -e "${GREEN}✅ Created sample .dockerignore at $dockerignore_file${NC}"
    fi
}

# Main execution
main() {
    local total_issues=0
    local files_checked=0

    echo "🐳 Dockerfile Best Practices Checker"
    echo "====================================="
    echo ""

    # Check each file passed as argument
    for file in "$@"; do
        if [[ -f "$file" ]]; then
            check_dockerfile "$file"
            local file_issues=$?
            total_issues=$((total_issues + file_issues))
            files_checked=$((files_checked + 1))

            # Offer to create .dockerignore
            dockerfile_dir=$(dirname "$file")
            if [[ ! -f "$dockerfile_dir/.dockerignore" ]]; then
                echo -e "${BLUE}💡 Would you like to create a sample .dockerignore? (recommended)${NC}"
                create_sample_dockerignore "$dockerfile_dir"
            fi

            echo "----------------------------------------"
        fi
    done

    echo ""
    echo "📊 Overall Summary:"
    echo "   Files checked: $files_checked"
    echo "   Total critical issues: $total_issues"
    echo ""

    if [[ $total_issues -gt 0 ]]; then
        echo -e "${RED}❌ Dockerfile check failed due to critical issues!${NC}"
        echo -e "${YELLOW}Please address the critical issues before committing.${NC}"
        echo ""
        echo "📚 Additional Resources:"
        echo "   • Docker Best Practices: https://docs.docker.com/develop/dev-best-practices/"
        echo "   • Dockerfile Best Practices: https://docs.docker.com/develop/dockerfile_best-practices/"
        echo "   • Container Security: https://kubernetes.io/docs/concepts/security/"
        exit 1
    else
        echo -e "${GREEN}✅ All Dockerfile checks passed!${NC}"
        exit 0
    fi
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
