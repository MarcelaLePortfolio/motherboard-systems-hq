
#!/bin/bash

set -e

BRANCH=$(git branch --show-current)

# 1. Ensure we're in a git repo

if [ ! -d ".git" ]; then

  echo "❌ Not a git repository"

  exit 1

fi

# 2. Block main branch commits

if [ "$BRANCH" = "main" ]; then

  echo "❌ Direct commits to main are blocked."

  echo "👉 Create a feature branch first:"

  echo "   git checkout -b feature/<name>"

  exit 1

fi

# 3. Safety check

echo "📦 Safe sync on branch: $BRANCH"

# 4. Commit all changes

git add -A

if git diff --cached --quiet; then

  echo "⚠️ No changes to commit"

  exit 0

fi

git commit -m "${1:-chore: safe sync}"

# 5. Push to current branch only

git push origin "$BRANCH"

echo "✅ Pushed safely to $BRANCH"

