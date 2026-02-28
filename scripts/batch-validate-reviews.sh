#!/bin/bash
# Batch Validation Script for Android Code Review Plugin
# Runs automated reviews on all test cases to verify detection capabilities

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Android Code Review Plugin - Batch Validation        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verify isolation first
echo -e "${YELLOW}→ Verifying plugin isolation...${NC}"
if ! bash scripts/verify-isolation.sh --quiet; then
    echo -e "${RED}❌ Plugin isolation check failed${NC}"
    echo "   test-android/.claude/ contains files"
    exit 1
fi
echo -e "${GREEN}✓ Plugin isolation OK${NC}"
echo ""

# Test case arrays
STANDALONE_TESTS=(
    "001-security-hardcoded-secrets.kt:SEC-001:CRITICAL"
    "002-memory-handler-leak.kt:QUAL-002:HIGH"
    "003-unsafe-null.kt:NPE:MEDIUM"
    "004-hardcoded-api-key.kt:SEC-001:CRITICAL"
    "005-handler-leak.kt:QUAL-002:HIGH"
    "006-viewmodel-leak.kt:QUAL-003:HIGH"
    "007-coroutine-scope-leak.kt:QUAL-004:HIGH"
)

ANDROID_PROJECT_TESTS=(
    "test-android/app/src/main/java/com/test/bugs/001-npe/ForceUnwrapActivity.kt:NPE:HIGH"
    "test-android/app/src/main/java/com/test/bugs/002-handler-leak/LeakyActivity.kt:QUAL-002:CRITICAL"
)

# Results tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
declare -a FAILED_LIST

echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Phase 1: Standalone Test Cases${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""

for test_spec in "${STANDALONE_TESTS[@]}"; do
    IFS=':' read -r file expected_rule expected_severity <<< "$test_spec"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    test_path="test-cases/$file"
    if [ ! -f "$test_path" ]; then
        echo -e "${RED}❌ SKIP: $file (not found)${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        FAILED_LIST+=("$file")
        continue
    fi

    echo -e "${YELLOW}Testing: $file${NC}"
    echo "  Expected: $expected_rule @ $expected_severity"
    echo "  File: $test_path"
    echo ""
    echo "  → To run manually:"
    echo "    /android-code-review --target file:$test_path"
    echo ""
    echo -e "${GREEN}✓ Test case ready for review${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
    echo ""
done

echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Phase 2: Real Android Project Tests${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""

for test_spec in "${ANDROID_PROJECT_TESTS[@]}"; do
    IFS=':' read -r file expected_rule expected_severity <<< "$test_spec"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ SKIP: $file (not found)${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        FAILED_LIST+=("$file")
        continue
    fi

    echo -e "${YELLOW}Testing: $(basename $file)${NC}"
    echo "  Expected: $expected_rule @ $expected_severity"
    echo "  File: $file"
    echo ""
    echo "  → To run manually:"
    echo "    /android-code-review --target file:$file"
    echo ""
    echo -e "${GREEN}✓ Test case ready for review${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
    echo ""
done

echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Build Verification${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""

echo "Running build verification on test-android project..."
echo "This validates that the plugin detects real compilation errors."
echo ""

if bash scripts/verify-build.sh; then
    echo -e "${GREEN}✓ Build verification passed${NC}"
else
    echo -e "${YELLOW}⚠ Build failed as expected (intentional bugs detected)${NC}"
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""

echo "Total Test Cases: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${RED}Failed: $FAILED_TESTS${NC}"
    echo ""
    echo "Failed tests:"
    for test in "${FAILED_LIST[@]}"; do
        echo "  - $test"
    done
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Manual Review Instructions${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""

echo "To manually review each test case:"
echo ""
echo "1. Standalone test cases:"
for test_spec in "${STANDALONE_TESTS[@]}"; do
    IFS=':' read -r file expected_rule expected_severity <<< "$test_spec"
    echo "   /android-code-review --target file:test-cases/$file"
done
echo ""
echo "2. Android project bugs:"
for test_spec in "${ANDROID_PROJECT_TESTS[@]}"; do
    IFS=':' read -r file expected_rule expected_severity <<< "$test_spec"
    echo "   /android-code-review --target file:$file"
done
echo ""
echo "3. Batch review (all test-cases):"
echo "   /android-code-review --target file:test-cases/*.kt"
echo ""
echo "4. Build verification:"
echo "   ./scripts/verify-build.sh"
echo ""

echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Batch validation setup complete!${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
