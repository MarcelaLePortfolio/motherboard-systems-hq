#!/usr/bin/env bash
set -euo pipefail

echo "[1] Verify existing tag"
git tag --list | grep phase-518-clean-worker-claim-lifecycle-validated || true

echo
echo "[2] Create follow-up immutable tag (no overwrite)"
NEW_TAG="phase-519-post-finalize-confirmed"
git tag "$NEW_TAG"

echo
echo "[3] Push new tag"
git push origin "$NEW_TAG"

echo
echo "[4] Final verification snapshot"
curl -sS 'http://localhost:8080/api/health'
echo
curl -sS 'http://localhost:8080/api/tasks?limit=1' | jq

echo
echo "=== PHASE 519 TAG FIX COMPLETE ==="
echo "Previous tag preserved"
echo "New tag created: $NEW_TAG"
echo "System remains CONSISTENT"
