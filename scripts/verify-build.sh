#!/bin/bash
# Verify test Android project can compile
# Does NOT use AI, directly calls Gradle

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_PROJECT="$PROJECT_ROOT/test-android"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔨 Verifying Android Project Build"
echo "=================================="
echo ""

if [ ! -d "$TEST_PROJECT" ]; then
    echo -e "${RED}❌ Test project not found: $TEST_PROJECT${NC}"
    echo ""
    echo "The test-android/ directory does not exist."
    echo "Please create it first following the design document:"
    echo "docs/plans/2026-02-27-android-test-project-integration-design.md"
    exit 1
fi

cd "$TEST_PROJECT"

if [ ! -f "gradlew" ]; then
    echo -e "${YELLOW}⚠️  Gradle wrapper not found${NC}"
    echo "Attempting to build with system gradle..."
    GRADLE_CMD="gradle"
else
    GRADLE_CMD="./gradlew"
fi

echo "Project: $(pwd)"
echo "Gradle: $GRADLE_CMD"
echo ""

echo -e "${YELLOW}Building project...${NC}"
echo "(This may take a minute on first run)"
echo ""

if $GRADLE_CMD assembleDebug --console=plain 2>&1; then
    echo ""
    echo -e "${GREEN}✅ Build SUCCESS${NC}"
    echo ""
    echo "The test project compiles successfully."
    echo "Plugin review results are validated."
    exit 0
else
    echo ""
    echo -e "${RED}❌ Build FAILED${NC}"
    echo ""
    echo "Possible reasons:"
    echo "  1. Code has actual errors (plugin was right)"
    echo "  2. Code has intentional bugs for testing"
    echo "  3. Gradle configuration issues"
    echo ""
    echo "Check the build output above for details."
    exit 1
fi
