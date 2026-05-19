
#!/bin/bash

set -euo pipefail

TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")

SNAPSHOT_DIR="backups/disaster-recovery/dr-$TIMESTAMP"

mkdir -p "$SNAPSHOT_DIR"

echo "Creating DR snapshot at: $SNAPSHOT_DIR"

echo "== Git State =="

git branch --show-current > "$SNAPSHOT_DIR/current-branch.txt"

git rev-parse HEAD > "$SNAPSHOT_DIR/current-commit.txt"

git remote -v > "$SNAPSHOT_DIR/git-remotes.txt"

git status --short > "$SNAPSHOT_DIR/git-status.txt"

echo "== Repository Tree =="

find . \

  -path "./node_modules" -prune -o \

  -path "./.git" -prune -o \

  -print > "$SNAPSHOT_DIR/repository-tree.txt"

echo "== PM2 State =="

pm2 list > "$SNAPSHOT_DIR/pm2-list.txt" 2>/dev/null || true

pm2 save > /dev/null 2>&1 || true

echo "== Docker State =="

docker ps -a > "$SNAPSHOT_DIR/docker-ps.txt" 2>/dev/null || true

echo "== Cloudflare Tunnel State =="

ls ~/.cloudflared > "$SNAPSHOT_DIR/cloudflare-files.txt" 2>/dev/null || true

echo "== Environment Metadata =="

node -v > "$SNAPSHOT_DIR/node-version.txt" 2>/dev/null || true

pnpm -v > "$SNAPSHOT_DIR/pnpm-version.txt" 2>/dev/null || true

echo "== Snapshot Manifest =="

cat > "$SNAPSHOT_DIR/manifest.txt" << MANIFEST

Timestamp: $TIMESTAMP

Repository: motherboard-systems-hq

Branch: $(git branch --show-current)

Commit: $(git rev-parse HEAD)

Purpose: Disaster recovery snapshot

Classification: Runtime-adjacent backup artifact

MANIFEST

echo "DR snapshot complete: $SNAPSHOT_DIR"

