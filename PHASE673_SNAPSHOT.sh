#!/usr/bin/env bash
set -euo pipefail

echo "Rebuilding containers for clean Phase 673 snapshot..."
docker compose up -d --build

echo "Creating snapshot archive..."
mkdir -p _snapshots
SNAP_NAME="_snapshots/phase673-complete-$(date +%Y%m%d-%H%M%S).tar.gz"

tar -czf "$SNAP_NAME" \
  --exclude node_modules \
  --exclude .git \
  --exclude _snapshots \
  .

echo "Snapshot created: $SNAP_NAME"

git add _snapshots
git commit -m "Phase 673: snapshot complete safe operator action layer build" || true
git push

echo "Phase 673 snapshot complete."
