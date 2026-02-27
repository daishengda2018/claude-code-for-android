#!/bin/bash
# Archive verified test cases to bugs-archive/

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUGS_DIR="$PROJECT_ROOT/test-android/app/src/main/java/com/test/bugs"
ARCHIVE_DIR="$PROJECT_ROOT/test-android/bugs-archive/$(date +%Y-%m)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ -z "$1" ]; then
    echo "Usage: ./scripts/archive-test.sh <test-id>"
    echo ""
    echo "Example:"
    echo "  ./scripts/archive-test.sh 001-npe"
    echo "  ./scripts/archive-test.sh 002-handler-leak"
    exit 1
fi

TEST_ID=$1

echo "📦 Archiving Test Case"
echo "======================"
echo ""

if [ ! -d "$BUGS_DIR/$TEST_ID" ]; then
    echo -e "${RED}❌ Test case not found: $BUGS_DIR/$TEST_ID${NC}"
    echo ""
    echo "Available test cases:"
    ls -1 "$BUGS_DIR" 2>/dev/null || echo "  (none)"
    exit 1
fi

mkdir -p "$ARCHIVE_DIR"

echo "Archiving: $TEST_ID"
echo "To: $ARCHIVE_DIR/"
echo ""

# Check if archive already contains same directory
if [ -d "$ARCHIVE_DIR/$TEST_ID" ]; then
    echo -e "${RED}❌ Archived version already exists: $ARCHIVE_DIR/$TEST_ID${NC}"
    exit 1
fi

# Move with error handling
mv "$BUGS_DIR/$TEST_ID" "$ARCHIVE_DIR/" || {
    echo -e "${RED}❌ Failed to archive $TEST_ID${NC}"
    exit 1
}

echo -e "${GREEN}✓ Archived $TEST_ID to $ARCHIVE_DIR/${NC}"
echo ""
echo "This test case has been archived and will no longer be tested"
echo "by default. It can be restored if needed for regression testing."
