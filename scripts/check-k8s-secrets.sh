#!/bin/bash
# check-k8s-secrets.sh - Check for hardcoded secrets in Kubernetes manifests

set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to check for potential secrets
check_secrets() {
    local file="$1"
    local issues_found=0

    # Patterns that might indicate hardcoded secrets
    declare -a patterns=(
        "password.*[:=].*[\"'][^\"']*[\"']"
        "apikey.*[:=].*[\"'][^\"']*[\"']"
        "api_key.*[:=].*[\"'][^\"']*[\"']"
        "secret.*[:=].*[\"'][^\"']*[\"']"
        "token.*[:=].*[\"'][^\"']*[\"']"
        "key.*[:=].*[\"'][^\"']{8,}[\"']"
        "cert.*[:=].*[\"'][^\"']*[\"']"
        "private.*[:=].*[\"'][^\"']*[\"']"
    )

    # Exceptions (values that are obviously not secrets)
    declare -a exceptions=(
        "changeme"
        "placeholder"
        "example"
        "sample"
        "dummy"
        "test"
        "demo"
        "default"
        "\${.*}"
        "\$\{.*\}"
        "secretKeyRef"
        "configMapKeyRef"
    )

    echo "🔍 Checking $file for potential hardcoded secrets..."

    for pattern in "${patterns[@]}"; do
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                # Extract the value part
                value=$(echo "$line" | grep -oE "${pattern}" | sed 's/.*[:=][[:space:]]*["\x27]//' | sed 's/["\x27].*//')

                # Check if it's an exception
                is_exception=false
                for exception in "${exceptions[@]}"; do
                    if [[ "$value" =~ $exception ]]; then
                        is_exception=true
                        break
                    fi
                done

                if [[ "$is_exception" == false ]] && [[ ${#value} -gt 3 ]]; then
                    echo -e "${RED}❌ Potential hardcoded secret found:${NC}"
                    echo -e "${YELLOW}   File: $file${NC}"
                    echo -e "${YELLOW}   Line: $line${NC}"
                    echo -e "${YELLOW}   Matched pattern: $pattern${NC}"
                    echo ""
                    issues_found=$((issues_found + 1))
                fi
            fi
        done < <(grep -n -i "$pattern" "$file" 2>/dev/null || true)
    done

    # Check for base64 encoded values that might be secrets
    while IFS= read -r line_info; do
        if [[ -n "$line_info" ]]; then
            line_number=$(echo "$line_info" | cut -d: -f1)
            line_content=$(echo "$line_info" | cut -d: -f2-)

            # Extract base64-like strings (longer than 20 chars)
            base64_values=$(echo "$line_content" | grep -oE '[A-Za-z0-9+/]{20,}={0,2}' || true)

            for value in $base64_values; do
                if [[ ${#value} -gt 20 ]]; then
                    echo -e "${YELLOW}⚠️  Potential base64 encoded secret found:${NC}"
                    echo -e "${YELLOW}   File: $file:$line_number${NC}"
                    echo -e "${YELLOW}   Value: ${value:0:20}...${NC}"
                    echo ""
                    issues_found=$((issues_found + 1))
                fi
            done
        fi
    done < <(grep -n '[A-Za-z0-9+/]\{20,\}' "$file" 2>/dev/null || true)

    return $issues_found
}

# Function to check if file should be scanned
should_scan_file() {
    local file="$1"

    # Skip certain directories and files
    if [[ "$file" =~ (vendor/|node_modules/|\.git/|istio-.*/) ]]; then
        return 1
    fi

    # Only scan YAML files
    if [[ "$file" =~ \.(yaml|yml)$ ]]; then
        return 0
    fi

    return 1
}

# Main execution
main() {
    local total_issues=0
    local files_scanned=0

    echo "🔐 Kubernetes Secrets Security Check"
    echo "===================================="
    echo ""

    # Check each file passed as argument
    for file in "$@"; do
        if [[ -f "$file" ]] && should_scan_file "$file"; then
            check_secrets "$file"
            local file_issues=$?
            total_issues=$((total_issues + file_issues))
            files_scanned=$((files_scanned + 1))
        fi
    done

    echo ""
    echo "📊 Summary:"
    echo "   Files scanned: $files_scanned"
    echo "   Issues found: $total_issues"
    echo ""

    if [[ $total_issues -gt 0 ]]; then
        echo -e "${RED}❌ Security check failed!${NC}"
        echo -e "${YELLOW}Please review the potential secrets found above.${NC}"
        echo -e "${YELLOW}Consider using Kubernetes secrets or external secret management.${NC}"
        echo ""
        echo "💡 Tips:"
        echo "   - Use secretKeyRef to reference Kubernetes secrets"
        echo "   - Use configMapKeyRef for non-sensitive configuration"
        echo "   - Consider External Secrets Operator for external secret stores"
        echo "   - Use environment variables instead of hardcoded values"
        exit 1
    else
        echo -e "${GREEN}✅ No potential secrets found!${NC}"
        exit 0
    fi
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
