#!/bin/bash
#
# Setup script for Git hooks
# Run this after cloning the repository to install pre-commit hooks
#

set -e

echo "🔧 Setting up Git hooks for 썸썸 (Thumb Some)..."

# Get the repository root directory
REPO_ROOT="$(git rev-parse --show-toplevel)"
HOOKS_DIR="$REPO_ROOT/.git/hooks"

# Check if we're in a git repository
if [ ! -d "$HOOKS_DIR" ]; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Copy pre-commit hook
echo "📋 Installing pre-commit hook..."
cp "$REPO_ROOT/scripts/hooks/pre-commit" "$HOOKS_DIR/pre-commit"
chmod +x "$HOOKS_DIR/pre-commit"

echo "✅ Pre-commit hook installed successfully!"
echo ""
echo "The hook will automatically run 'dart format' before each commit."
echo "This ensures your code always passes CI formatting checks."
echo ""
echo "To bypass the hook temporarily, use: git commit --no-verify"
echo ""
echo "Happy coding! 🎉"
