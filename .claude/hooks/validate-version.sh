#!/bin/bash
# Version validation script for claude-code-for-android plugin releases
# Usage: .claude/hooks/validate-version.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track errors
ERRORS=0
WARNINGS=0

# Function to print error
error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
    ERRORS=$((ERRORS + 1))
}

# Function to print warning
warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
    WARNINGS=$((WARNINGS + 1))
}

# Function to print success
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

echo "🔍 Validating plugin version consistency..."
echo ""

# Check if required files exist
if [ ! -f ".claude/plugin-manifest.json" ]; then
    error "plugin-manifest.json not found"
    exit 1
fi

if [ ! -f ".claude-plugin/marketplace.json" ]; then
    error "marketplace.json not found"
    exit 1
fi

if [ ! -f "CHANGELOG.md" ]; then
    warning "CHANGELOG.md not found"
fi

# Extract version numbers using cross-platform sed
PLUGIN_VERSION=$(grep -m 1 '"version"' .claude/plugin-manifest.json | sed 's/.*"version": *"\([^"]*\)".*/\1/')
MARKETPLACE_VERSION=$(grep -m 1 '"version"' .claude-plugin/marketplace.json | sed 's/.*"version": *"\([^"]*\)".*/\1/')

echo "📦 Version numbers found:"
echo "  - plugin-manifest.json: $PLUGIN_VERSION"
echo "  - marketplace.json:     $MARKETPLACE_VERSION"
echo ""

# Validate semver format (basic check: X.Y.Z or X.Y.Z-*)
validate_semver() {
    local version=$1
    if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$ ]]; then
        return 1
    fi
    return 0
}

# Check version format
if ! validate_semver "$PLUGIN_VERSION"; then
    error "plugin-manifest.json version '$PLUGIN_VERSION' does not follow semver format"
else
    success "plugin-manifest.json version format is valid"
fi

if ! validate_semver "$MARKETPLACE_VERSION"; then
    error "marketplace.json version '$MARKETPLACE_VERSION' does not follow semver format"
else
    success "marketplace.json version format is valid"
fi

# Check version consistency
if [ "$PLUGIN_VERSION" != "$MARKETPLACE_VERSION" ]; then
    error "Version mismatch between plugin-manifest.json and marketplace.json"
    exit 1
else
    success "Version numbers are consistent across all files"
fi

# Check CHANGELOG.md if it exists
if [ -f "CHANGELOG.md" ]; then
    if grep -q "\[$PLUGIN_VERSION\]" CHANGELOG.md; then
        success "CHANGELOG.md contains entry for version $PLUGIN_VERSION"
    else
        warning "CHANGELOG.md does not contain entry for version $PLUGIN_VERSION"
    fi
fi

# Check for common version string errors
echo ""
echo "🔍 Checking for common version string issues..."

# Check if version still contains placeholder text
if [[ "$PLUGIN_VERSION" =~ [0-9]+\.[0-9]+\.[0-9]+-(alpha|beta|rc) ]]; then
    warning "Version appears to be a pre-release version: $PLUGIN_VERSION"
    echo "   Consider if this is ready for stable release"
fi

# Check if description versions match
PLUGIN_DESC_VERSION=$(grep -o "v[0-9]\+\.[0-9]\+\.[0-9]\+" .claude/plugin-manifest.json | head -1)
MARKETPLACE_DESC_VERSION=$(grep -o "v[0-9]\+\.[0-9]\+\.[0-9]\+" .claude-plugin/marketplace.json | head -1)

if [ -n "$PLUGIN_DESC_VERSION" ] && [ "$PLUGIN_DESC_VERSION" != "v$PLUGIN_VERSION" ]; then
    warning "plugin-manifest.json description mentions version $PLUGIN_DESC_VERSION but version is $PLUGIN_VERSION"
fi

if [ -n "$MARKETPLACE_DESC_VERSION" ] && [ "$MARKETPLACE_DESC_VERSION" != "v$PLUGIN_VERSION" ]; then
    warning "marketplace.json description mentions version $MARKETPLACE_DESC_VERSION but version is $PLUGIN_VERSION"
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ All version checks passed!${NC}"
    echo "Ready for release: v$PLUGIN_VERSION"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Version validation passed with $WARNINGS warning(s)${NC}"
    echo "Please review warnings before release"
    exit 0
else
    echo -e "${RED}❌ Version validation failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
    echo "Please fix errors before release"
    exit 1
fi
