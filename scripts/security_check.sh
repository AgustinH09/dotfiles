#!/usr/bin/env bash
#
# Local Security Check Script
# Run this before pushing to catch issues early
#
# Usage: ./scripts/security-check.sh [--fix]
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
WARNINGS=0
ERRORS=0
CHECKS_PASSED=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

echo -e "${BLUE}🔐 Running Local Security Checks${NC}"
echo "Repository: $REPO_ROOT"
echo ""

print_section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_result() {
    local status=$1
    local message=$2

    if [ "$status" = "pass" ]; then
        echo -e "${GREEN}✅ $message${NC}"
        ((CHECKS_PASSED++))
    elif [ "$status" = "warn" ]; then
        echo -e "${YELLOW}⚠️  $message${NC}"
        ((WARNINGS++))
    elif [ "$status" = "fail" ]; then
        echo -e "${RED}❌ $message${NC}"
        ((ERRORS++))
    else
        echo -e "$message"
    fi
}

print_section "1. Checking for Hardcoded Paths"

HARDCODED_PATHS=$(grep -r -n "/home/chicha09" \
    --exclude-dir=".git" \
    --exclude-dir="node_modules" \
    --exclude-dir=".tmux" \
    --exclude="*.age" \
    --exclude="*.md" \
    --exclude="security-check.sh" --exclude="security_check.sh" --exclude-dir=".github" --exclude="symlink_*" \
    . 2>/dev/null || true)

if [ -n "$HARDCODED_PATHS" ]; then
    print_result "warn" "Hardcoded paths found (portability issue):"
    echo "$HARDCODED_PATHS" | head -10
    HARDCODED_COUNT=$(echo "$HARDCODED_PATHS" | wc -l)
    if [ "$HARDCODED_COUNT" -gt 10 ]; then
        echo "... and $((HARDCODED_COUNT - 10)) more"
    fi
else
    print_result "pass" "No hardcoded paths found"
fi

print_section "2. Checking for Unencrypted Sensitive Files"

SENSITIVE_PATTERNS=("*.pem" "*.key" "*token*" "*secret*" "*password*" "*.gpg" "*credentials*")
FOUND_UNENCRYPTED=0

for pattern in "${SENSITIVE_PATTERNS[@]}"; do
    while IFS= read -r file; do
        if [[ ! "$file" =~ \.age$ ]] && \
           [[ ! "$file" =~ ^\.git/ ]] && \
           [[ ! "$file" =~ node_modules/ ]] && \
           [[ ! "$file" =~ \.github/workflows/ ]] && \
           [[ ! "$file" =~ scripts/security-check\.sh$ ]]; then

            if [ $FOUND_UNENCRYPTED -eq 0 ]; then
                print_result "fail" "Unencrypted sensitive files found:"
            fi
            echo "  - $file"
            FOUND_UNENCRYPTED=1
        fi
    done < <(find . -type f -iname "$pattern" 2>/dev/null || true)
done

if [ $FOUND_UNENCRYPTED -eq 0 ]; then
    print_result "pass" "All sensitive files are encrypted"
fi

print_section "3. Checking for Exposed API Keys"

API_KEYS=$(grep -r -n -E '(API_KEY|SECRET|TOKEN|PASSWORD)\s*=\s*["\047][a-zA-Z0-9_-]{20,}["\047]' \
    --exclude-dir=".git" \
    --exclude-dir="node_modules" \
    --exclude="*.age" \
    --exclude="*.md" \
    --exclude="security-check.sh" --exclude="security_check.sh" --exclude-dir=".github" --exclude="symlink_*" \
    . 2>/dev/null || true)

if [ -n "$API_KEYS" ]; then
    print_result "fail" "Potential API keys found in code:"
    echo "$API_KEYS"
else
    print_result "pass" "No exposed API keys found"
fi

print_section "4. Checking for Private Keys"

PRIVATE_KEYS=$(grep -r -n "BEGIN.*PRIVATE KEY" \
    --exclude-dir=".git" \
    --exclude-dir="node_modules" \
    --exclude="*.age" \
    --exclude="*.md" \
    . 2>/dev/null || true)

if [ -n "$PRIVATE_KEYS" ]; then
    print_result "fail" "Unencrypted private keys found:"
    echo "$PRIVATE_KEYS"
else
    print_result "pass" "No unencrypted private keys found"
fi

print_section "5. Validating Chezmoi Configuration"

if [ -f "chezmoi.toml" ]; then
    print_result "pass" "chezmoi.toml exists"
    if grep -q "encryption" chezmoi.toml; then
        print_result "pass" "Encryption is configured"
    else
        print_result "warn" "No encryption configuration found in chezmoi.toml"
    fi
elif [ -f ".chezmoi.toml.tmpl" ]; then
    print_result "pass" ".chezmoi.toml.tmpl exists"
    if grep -q "encryption" .chezmoi.toml.tmpl; then
        print_result "pass" "Encryption is configured (template)"
    else
        print_result "warn" "No encryption configuration found in .chezmoi.toml.tmpl"
    fi
else
    print_result "fail" "chezmoi configuration file not found (chezmoi.toml or .chezmoi.toml.tmpl)"
fi

if [ -f ".chezmoiignore" ]; then
    print_result "pass" ".chezmoiignore exists"
    if grep -q "key.txt" .chezmoiignore; then
        print_result "pass" "Private key is properly ignored"
    else
        print_result "warn" "Private key may not be ignored in .chezmoiignore"
    fi
elif [ -f ".chezmoiignore.tmpl" ]; then
    print_result "pass" ".chezmoiignore.tmpl exists"
    if grep -q "key.txt" .chezmoiignore.tmpl; then
        print_result "pass" "Private key is properly ignored (template)"
    else
        print_result "warn" "Private key may not be ignored in .chezmoiignore.tmpl"
    fi
else
    print_result "warn" "chezmoi ignore file not found (.chezmoiignore or .chezmoiignore.tmpl)"
fi

print_section "6. Checking Git Status"

if [ -n "$(git status --porcelain)" ]; then
    print_result "warn" "Uncommitted changes detected"
    git status --short
else
    print_result "pass" "Working tree is clean"
fi

print_section "7. Validating .gitignore"

if [ -f ".gitignore" ]; then
    print_result "pass" ".gitignore exists"

    REQUIRED_PATTERNS=("key.txt" "*.key" "*.pem" "*token*")
    for pattern in "${REQUIRED_PATTERNS[@]}"; do
        if grep -q "$pattern" .gitignore; then
            print_result "pass" "Pattern '$pattern' is in .gitignore"
        else
            print_result "warn" "Pattern '$pattern' not found in .gitignore"
        fi
    done
else
    print_result "fail" ".gitignore not found"
fi

print_section "8. Running Gitleaks (if available)"

if command -v gitleaks &> /dev/null; then
    echo "Running Gitleaks scan..."
    if gitleaks detect --source . --no-git --exit-code 0 --report-format json --report-path /tmp/gitleaks-report.json 2>&1 | grep -q "No leaks found"; then
        print_result "pass" "Gitleaks: No secrets detected"
    else
        if [ -f /tmp/gitleaks-report.json ]; then
            LEAK_COUNT=$(jq '. | length' /tmp/gitleaks-report.json 2>/dev/null || echo "unknown")
            print_result "fail" "Gitleaks: $LEAK_COUNT potential secret(s) found"
            echo "Run 'gitleaks detect --source . --verbose' for details"
        else
            print_result "warn" "Gitleaks scan completed with warnings"
        fi
    fi
    rm -f /tmp/gitleaks-report.json
else
    print_result "warn" "Gitleaks not installed (optional)"
    echo "  Install: brew install gitleaks (macOS) or see https://github.com/gitleaks/gitleaks"
fi

print_section "Summary"

echo ""
echo -e "${GREEN}✅ Checks Passed: $CHECKS_PASSED${NC}"
echo -e "${YELLOW}⚠️  Warnings: $WARNINGS${NC}"
echo -e "${RED}❌ Errors: $ERRORS${NC}"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}🚨 Security issues found! Please fix before committing.${NC}"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Warnings found. Review before pushing.${NC}"
    exit 0
else
    echo -e "${GREEN}🎉 All security checks passed!${NC}"
    exit 0
fi
