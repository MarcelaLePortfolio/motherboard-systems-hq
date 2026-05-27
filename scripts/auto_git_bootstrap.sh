
#!/bin/bash

set -euo pipefail

echo "🧠 Auto Git Bootstrap (Zero Manual Mode)"

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

cd "$PROJECT_ROOT"

# Ensure git exists

if [ ! -d .git ]; then

  echo "🔧 Initializing git..."

  git init

fi

# Stage everything safely

git add -A

# Commit only if changes exist

if git diff --cached --quiet; then

  echo "⚠️ No changes to commit"

else

  git commit -m "auto-bootstrap: system sync $(date +%Y%m%d_%H%M%S)"

fi

# Detect remote (safe fallback)

REMOTE_URL="$(git remote get-url origin 2>/dev/null || true)"

if [ -z "$REMOTE_URL" ]; then

  echo "⚠️ No remote configured (safe exit)"

  exit 0

fi

BRANCH="$(git rev-parse --abbrev-ref HEAD)"

echo "🚀 Pushing to origin/$BRANCH..."

git push origin "$BRANCH" || {

  echo "⚠️ Push failed safely"

  exit 0

}

echo "✅ AUTO BOOTSTRAP COMPLETE"

