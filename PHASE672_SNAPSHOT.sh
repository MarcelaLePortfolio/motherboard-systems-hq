#!/usr/bin/env bash
set -euo pipefail

echo "Rebuilding containers for clean Phase 672 snapshot..."
docker compose up -d --build

echo "Creating snapshot archive..."
mkdir -p _snapshots
SNAP_NAME="_snapshots/phase672-complete-$(date +%Y%m%d-%H%M%S).tar.gz"

tar -czf "$SNAP_NAME" \
  --exclude node_modules \
  --exclude .git \
  --exclude _snapshots \
  .

echo "Snapshot created: $SNAP_NAME"

git add _snapshots
git commit -m "Phase 672: snapshot complete guidance UX refined build" || true
git push

echo "Phase 672 snapshot complete."
