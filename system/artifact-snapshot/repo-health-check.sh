
#!/bin/bash

set -euo pipefail

echo "=== REPO HEALTH CHECK ==="

echo "Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"

echo

echo "=== Current Directory ==="

pwd

echo

echo "=== Git Root ==="

git rev-parse --show-toplevel

echo

echo "=== Branch ==="

git branch --show-current

echo

echo "=== Remotes ==="

git remote -v

echo

echo "=== Upstream Tracking ==="

git status -sb

echo

echo "=== Latest Commit ==="

git log -1 --oneline

echo

echo "=== Working Tree Status ==="

git status --short

echo

