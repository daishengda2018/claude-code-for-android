#!/bin/bash
# Publish Plugin Update

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🚀 Plugin Publishing Script"
echo "============================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Detect OS for cross-platform sed compatibility
if [[ "$OSTYPE" == "darwin"* ]]; then
    SED_FLAG="-i ''"
else
    SED_FLAG="-i"
fi

# Get current version
CURRENT_VERSION=$(grep '"version"' "$PROJECT_ROOT/.claude/plugin-manifest.json" | cut -d'"' -f4)

echo "Current version: ${BLUE}${CURRENT_VERSION}${NC}"
echo ""

# Prompt for new version
read -p "Enter new version (e.g., 1.0.2): " NEW_VERSION

if [ -z "$NEW_VERSION" ]; then
    echo -e "${RED}Error: Version cannot be empty${NC}"
    exit 1
fi

echo ""
echo "This will:"
echo "  1. Update version to ${BLUE}${NEW_VERSION}${NC}"
echo "  2. Commit changes"
echo "  3. Create git tag"
echo "  4. Push to remote"
echo "  5. Create GitHub release"
echo ""

read -p "Continue? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

# Update version in plugin-manifest.json
echo -e "${YELLOW}Updating plugin-manifest.json...${NC}"
sed $SED_FLAG "s/\"version\": \"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/" \
    "$PROJECT_ROOT/.claude/plugin-manifest.json"

# Update version in marketplace.json
echo -e "${YELLOW}Updating marketplace.json...${NC}"
sed $SED_FLAG "s/\"version\": \"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/" \
    "$PROJECT_ROOT/.claude-plugin/marketplace.json"

# Commit changes
echo -e "${YELLOW}Committing changes...${NC}"
git add .claude/plugin-manifest.json .claude-plugin/marketplace.json
git commit -m "chore: Bump version to ${NEW_VERSION}

- Update plugin-manifest.json
- Update marketplace.json
- Test and verify all functionality"

# Push to remote
echo -e "${YELLOW}Pushing to remote...${NC}"
git push origin main

# Create tag
echo -e "${YELLOW}Creating git tag...${NC}"
git tag -a "v${NEW_VERSION}" -m "Release v${NEW_VERSION}

See GitHub release for details."
git push origin "v${NEW_VERSION}"

# Prompt for GitHub release
echo ""
echo -e "${GREEN}✓ Version ${NEW_VERSION} tagged and pushed!${NC}"
echo ""
echo "Next steps:"
echo "  1. Create GitHub release:"
echo "     gh release create v${NEW_VERSION} --notes 'Release notes here'"
echo "  2. Users can update with:"
echo "     /plugin marketplace add daishengda2018/claude-code-for-android@v${NEW_VERSION}"
echo ""
