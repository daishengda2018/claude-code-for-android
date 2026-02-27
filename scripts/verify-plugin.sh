#!/bin/bash
# Verify Plugin Functionality

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_CASES_DIR="$PROJECT_ROOT/test-cases"

echo "🧪 Plugin Verification Script"
echo "=============================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test results
TOTAL=0
PASSED=0
FAILED=0

# Function to verify a single test case
verify_test_case() {
    local test_file=$1
    local test_name=$(basename "$test_file" .kt)

    TOTAL=$((TOTAL + 1))

    echo -e "${BLUE}Test $TOTAL: ${test_name}${NC}"

    # Extract expected detection
    local expected=$(grep "Expected Detection:" "$test_file" | cut -d: -f2 | tr -d ' ')

    # Extract checklist items
    local checklist_items=$(grep -c "^\[ \]" "$test_file" || echo "0")

    echo "  Expected severity: ${YELLOW}${expected}${NC}"
    echo "  Checklist items: ${checklist_items}"
    echo ""

    # Manual verification prompt
    echo -e "${YELLOW}Manual verification required:${NC}"
    echo "  1. Run: /android-code-review --target file:$test_file"
    echo "  2. Check if all issues are detected"
    echo "  3. Verify severity is correct"
    echo ""

    read -p "Did the plugin pass this test? (y/n) " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        PASSED=$((PASSED + 1))
        echo -e "  ${GREEN}✓ PASSED${NC}"
    else
        FAILED=$((FAILED + 1))
        echo -e "  ${RED}✗ FAILED${NC}"
        echo "  → Add improvements to: .claude/agents/android-code-reviewer.md"
    fi

    echo "----------------------------------------"
    echo ""
}

# Main execution
echo "This script will verify all test cases."
echo "Make sure you have restarted Claude Code after plugin changes."
echo ""

read -p "Press Enter to start verification..."
echo ""

# Verify all test cases
for test_file in "$TEST_CASES_DIR"/*.kt; do
    if [ -f "$test_file" ]; then
        verify_test_case "$test_file"
    fi
done

# Summary
echo ""
echo "=============================="
echo "Verification Summary:"
echo -e "  Total:   ${BLUE}${TOTAL}${NC}"
echo -e "  Passed:  ${GREEN}${PASSED}${NC}"
echo -e "  Failed:  ${RED}${FAILED}${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed! Ready to release.${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Some tests failed. Improve the plugin and re-run.${NC}"
    exit 1
fi
