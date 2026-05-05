#!/bin/bash
set -e

PHASE_TAG="phase677-final-seal"
SNAPSHOT_NAME="snapshot_phase677_final_seal.tar.gz"

echo "=== Git status before seal ==="
git status --short

echo ""
echo "=== Commit any uncommitted seal artifacts if present ==="
git add .
git commit -m "Phase 677: final seal before persistence-aware coherence planning" || true

echo ""
echo "=== Tag final Phase 677 seal ==="
git tag -f "$PHASE_TAG"

echo ""
echo "=== Push branch and tag ==="
git push
git push origin "$PHASE_TAG" --force

echo ""
echo "=== Rebuild and verify containers ==="
docker compose up -d --build
docker compose ps

echo ""
echo "=== Validate active coherence route ==="
curl -i -s http://localhost:3000/api/guidance/coherence-shadow | head -c 1200
printf '\n'

echo ""
echo "=== Create local snapshot ==="
tar --exclude='.git' --exclude='node_modules' --exclude='.next' -czf "$SNAPSHOT_NAME" .

echo ""
echo "=== Snapshot complete ==="
ls -lh "$SNAPSHOT_NAME"
