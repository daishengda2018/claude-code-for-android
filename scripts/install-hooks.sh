#!/bin/bash
# Install git hooks for language convention enforcement

set -e

HOOKS_DIR=".git/hooks"
SCRIPT_DIR="hooks"

echo "🔧 Installing git hooks for language convention enforcement..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not a git repository!"
    echo "   Run this script from the repository root."
    exit 1
fi

# Check if hooks directory exists
if [ ! -d "$HOOKS_DIR" ]; then
    echo "❌ Error: .git/hooks directory not found!"
    exit 1
fi

# Copy hooks
echo ""
echo "📋 Installing hooks..."

# Commit message hook
if [ -f "$SCRIPT_DIR/commit-msg" ]; then
    cp "$SCRIPT_DIR/commit-msg" "$HOOKS_DIR/commit-msg"
    chmod +x "$HOOKS_DIR/commit-msg"
    echo "   ✅ commit-msg hook installed"
else
    echo "   ⚠️  Warning: commit-msg hook not found in $SCRIPT_DIR"
fi

# Pre-commit hook
if [ -f "$SCRIPT_DIR/pre-commit" ]; then
    cp "$SCRIPT_DIR/pre-commit" "$HOOKS_DIR/pre-commit"
    chmod +x "$HOOKS_DIR/pre-commit"
    echo "   ✅ pre-commit hook installed"
else
    echo "   ⚠️  Warning: pre-commit hook not found in $SCRIPT_DIR"
fi

echo ""
echo "✅ Git hooks installed successfully!"
echo ""
echo "📖 What to expect:"
echo "   • Commit messages must be in English"
echo "   • Documentation files must be in English"
echo "   • Code comments should be in English (warnings only)"
echo "   • File names must use English"
echo ""
echo "🔗 To bypass hooks temporarily (not recommended):"
echo "   git commit --no-verify -m 'message'"
echo ""
echo "📚 See CONVENTIONS.md for full language convention guidelines."
