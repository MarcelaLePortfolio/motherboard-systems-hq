#!/bin/bash
set -e

SNAPSHOT_NAME="snapshot_phase677_final_seal.tar.gz"

echo "=== Remove incomplete snapshot if present ==="
rm -f "$SNAPSHOT_NAME"

echo ""
echo "=== Create corrected local snapshot ==="
tar \
  --exclude='.git' \
  --exclude='node_modules' \
  --exclude='.next' \
  --exclude="$SNAPSHOT_NAME" \
  -czf "$SNAPSHOT_NAME" .

echo ""
echo "=== Snapshot complete ==="
ls -lh "$SNAPSHOT_NAME"

echo ""
echo "=== Verify Phase 677 tag ==="
git tag --list "phase677-final-seal"

echo ""
echo "=== Verify route still active ==="
curl -i -s http://localhost:3000/api/guidance/coherence-shadow | head -c 600
printf '\n'
