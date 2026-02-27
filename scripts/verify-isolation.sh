#!/bin/bash
# Verify plugin isolation configuration
# Returns 0=pass, 1=fail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_PROJECT="$PROJECT_ROOT/test-android"

# Quiet mode (no output, just return exit code)
QUIET=${1:-""}

if [ -d "$TEST_PROJECT/.claude" ] && [ "$(ls -A $TEST_PROJECT/.claude 2>/dev/null)" ]; then
    if [ -z "$QUIET" ]; then
        echo "❌ Isolation check FAILED"
        echo "   test-android/.claude/ exists and contains files"
        echo ""
        echo "This will prevent loading the development plugin!"
        echo "Remove with: rm -rf $TEST_PROJECT/.claude"
    fi
    exit 1
fi

if [ -z "$QUIET" ]; then
    echo "✓ Plugin isolation OK"
fi
exit 0
