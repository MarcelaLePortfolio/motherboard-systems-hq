
#!/usr/bin/env bash

set -euo pipefail

ROOT="/Volumes/Rio Drive/backups"

echo "===== RIO DRIVE DR VERIFICATION ====="

date

echo

echo "===== NEWEST SOURCE ARCHIVES ====="

ls -lh "$ROOT"/source_*.tar.gz 2>/dev/null | tail -10 || true

echo

echo "===== ANY REPO BUNDLES ANYWHERE ====="

find "$ROOT" -type f -name "*.bundle" -exec ls -lh {} \; 2>/dev/null | sort -k6,8 || true

echo

echo "===== STAGING DIRECTORIES ====="

find "$ROOT" -maxdepth 1 -type d -name ".staging*" -exec ls -ldh {} \; 2>/dev/null || true

echo

echo "===== LATEST SOURCE ARCHIVE CONTENT SAMPLE ====="

LATEST_SOURCE="$(ls -t "$ROOT"/source_*.tar.gz 2>/dev/null | head -1 || true)"

if [ -n "$LATEST_SOURCE" ]; then

  echo "$LATEST_SOURCE"

  tar -tzf "$LATEST_SOURCE" | head -40

else

  echo "No source archive found"

fi

echo

echo "===== CURRENT GIT HEAD ====="

git log --oneline -5

echo

echo "===== WORKTREE ====="

git status --short

