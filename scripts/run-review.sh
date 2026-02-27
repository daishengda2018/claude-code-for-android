#!/bin/bash
# Run Android Code Review on Test Cases

set -e  # Abort on any error

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_CASES_DIR="$PROJECT_ROOT/test-cases"

# Auto-verify plugin isolation before running
if ! bash "$PROJECT_ROOT/scripts/verify-isolation.sh" --quiet; then
    echo ""
    echo "❌ Cannot proceed: Plugin isolation check failed"
    echo ""
    bash "$PROJECT_ROOT/scripts/verify-isolation.sh"
    echo ""
    echo "The development plugin cannot be loaded while test-android/.claude/ exists."
    exit 1
fi

echo "🔍 Android Code Review - Test Runner"
echo "===================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to run review on a single test case
run_review() {
    local test_file=$1
    local test_name=$(basename "$test_file" .kt)

    echo -e "${YELLOW}Testing: ${test_name}${NC}"
    echo "File: $test_file"
    echo ""

    # Run the review
    echo "Expected issues:"
    grep "Expected Detection:" "$test_file" || echo "  None specified"
    echo ""

    # Count expected issues
    expected_count=$(grep -c "^\[ \]" "$test_file" || true)
    echo "Checklist items: $expected_count"
    echo ""

    read -p "Press Enter to run review..."
    echo ""

    # In Claude Code, this would trigger the agent
    echo "📝 Run: /android-code-review --target file:$test_file"
    echo ""

    # Separator
    echo "----------------------------------------"
    echo ""
}

# Main execution
if [ $# -eq 0 ]; then
    # Run all test cases
    for test_file in "$TEST_CASES_DIR"/*.kt; do
        if [ -f "$test_file" ]; then
            run_review "$test_file"
        fi
    done
else
    # Run specific test case
    test_file="$TEST_CASES_DIR/$1.kt"
    if [ -f "$test_file" ]; then
        run_review "$test_file"
    else
        echo -e "${RED}Error: Test case not found: $test_file${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✓ Test run completed!${NC}"
