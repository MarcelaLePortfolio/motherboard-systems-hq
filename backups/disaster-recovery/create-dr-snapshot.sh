
#!/bin/bash

set -euo pipefail

EXPECTED_ROOT="/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

ACTUAL_ROOT="$(git rev-parse --show-toplevel)"

if [ "$ACTUAL_ROOT" != "$EXPECTED_ROOT" ]; then

  echo "DR snapshot aborted: wrong repository root."

  echo "Expected: $EXPECTED_ROOT"

  echo "Actual:   $ACTUAL_ROOT"

  exit 1

fi

cd "$ACTUAL_ROOT"

TIMESTAMP="$(date -u +"%Y%m%dT%H%M%SZ")"

SNAPSHOT_DIR="backups/disaster-recovery/dr-$TIMESTAMP"

mkdir -p "$SNAPSHOT_DIR"

echo "Creating DR snapshot at: $SNAPSHOT_DIR"

git branch --show-current > "$SNAPSHOT_DIR/current-branch.txt"

git rev-parse HEAD > "$SNAPSHOT_DIR/current-commit.txt"

git remote -v > "$SNAPSHOT_DIR/git-remotes.txt"

git status --short > "$SNAPSHOT_DIR/git-status.txt"

git status -sb > "$SNAPSHOT_DIR/git-status-branch.txt"

git log -1 --oneline > "$SNAPSHOT_DIR/latest-commit.txt"

find . \

  \( -path "./node_modules" -o -path "./.git" -o -path "./backups/disaster-recovery/dr-*" \) -prune \

  -o -print > "$SNAPSHOT_DIR/repository-tree.txt"

pm2 list > "$SNAPSHOT_DIR/pm2-list.txt" 2>/dev/null || true

pm2 save > /dev/null 2>&1 || true

docker ps -a > "$SNAPSHOT_DIR/docker-ps.txt" 2>/dev/null || true

ls ~/.cloudflared > "$SNAPSHOT_DIR/cloudflare-files.txt" 2>/dev/null || true

node -v > "$SNAPSHOT_DIR/node-version.txt" 2>/dev/null || true

pnpm -v > "$SNAPSHOT_DIR/pnpm-version.txt" 2>/dev/null || true

cat > "$SNAPSHOT_DIR/manifest.txt" << MANIFEST

Timestamp: $TIMESTAMP

Repository: motherboard-systems-hq

Root: $ACTUAL_ROOT

Branch: $(git branch --show-current)

Commit: $(git rev-parse HEAD)

Purpose: Disaster recovery snapshot

Classification: Runtime-adjacent backup artifact

Status: complete

MANIFEST

echo "DR snapshot complete: $SNAPSHOT_DIR"

