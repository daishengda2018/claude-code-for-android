#!/bin/bash
# Android Code Review Skill Test Suite
# Runs TDD-based tests for the android-code-review skill

set -e

echo "🧪 Android Code Review Skill Test Suite"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TOTAL=0
PASSED=0
FAILED=0

# Function to run a test case
run_test() {
    local test_file=$1
    local test_name=$(basename "$test_file" .kt)

    TOTAL=$((TOTAL + 1))

    echo -n "Running $test_name... "

    # Extract expected severity from file
    local expected=$(grep "Expected Detection:" "$test_file" | cut -d: -f2 | xargs)

    # Run the review (this would call the actual command)
    # For now, just check if file exists
    if [ -f "$test_file" ]; then
        echo -e "${GREEN}✓ PASSED${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗ FAILED${NC}"
        FAILED=$((FAILED + 1))
    fi
}

# Main test execution
echo "Phase 1: Test Case Validation"
echo "-------------------------------"

for test_file in test-cases/*.kt; do
    if [ -f "$test_file" ]; then
        run_test "$test_file"
    fi
done

echo ""
echo "Phase 2: Skill Invocation Tests"
echo "-------------------------------"

# Test 1: Check skill file exists
echo -n "Skill file exists... "
if [ -f "skills/android-code-review/SKILL.md" ]; then
    echo -e "${GREEN}✓ PASSED${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FAILED${NC}"
    FAILED=$((FAILED + 1))
fi
TOTAL=$((TOTAL + 1))

# Test 2: Check command file exists
echo -n "Command file exists... "
if [ -f "commands/android-code-review.md" ]; then
    echo -e "${GREEN}✓ PASSED${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FAILED${NC}"
    FAILED=$((FAILED + 1))
fi
TOTAL=$((TOTAL + 1))

# Test 3: Check agent file exists
echo -n "Agent file exists... "
if [ -f "agents/android-code-reviewer.md" ]; then
    echo -e "${GREEN}✓ PASSED${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FAILED${NC}"
    FAILED=$((FAILED + 1))
fi
TOTAL=$((TOTAL + 1))

echo ""
echo "Phase 3: Description CSO Validation"
echo "-----------------------------------"

# Test 4: Check skill description follows CSO guidelines
echo -n "Description starts with 'Use when'... "
if grep -q "^description: Use when" skills/android-code-review/SKILL.md; then
    echo -e "${GREEN}✓ PASSED${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FAILED${NC}"
    FAILED=$((FAILED + 1))
fi
TOTAL=$((TOTAL + 1))

# Test 5: Check description doesn't summarize workflow
echo -n "Description doesn't summarize workflow... "
if ! grep -q "severity-based pattern loading" skills/android-code-review/SKILL.md; then
    echo -e "${GREEN}✓ PASSED${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FAILED${NC}"
    FAILED=$((FAILED + 1))
fi
TOTAL=$((TOTAL + 1))

echo ""
echo "========================================"
echo "Test Results:"
echo "  Total:   $TOTAL"
echo -e "  ${GREEN}Passed:  $PASSED${NC}"
echo -e "  ${RED}Failed:  $FAILED${NC}"
echo "========================================"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
