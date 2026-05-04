#!/usr/bin/env bash
set -euo pipefail

echo "Rebuilding containers for clean Phase 670 snapshot..."
docker compose up -d --build

echo "Creating snapshot archive..."
mkdir -p _snapshots
SNAP_NAME="_snapshots/phase670-complete-$(date +%Y%m%d-%H%M%S).tar.gz"

tar -czf "$SNAP_NAME" \
  --exclude node_modules \
  --exclude .git \
  --exclude _snapshots \
  .

echo "Snapshot created: $SNAP_NAME"

git add _snapshots
git commit -m "Phase 670: snapshot complete guidance UI aligned build" || true
git push

echo "Phase 670 snapshot complete."
