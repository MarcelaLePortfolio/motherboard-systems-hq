#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "===== PHASE 487 — COMMIT SURGICAL HELPER ====="

TARGET="scripts/_local/phase487_surgical_merge_limited_guidance_into_index.sh"

if [ ! -f "$TARGET" ]; then
  echo "ERROR: $TARGET not found"
  exit 1
fi

echo
echo "[1] ADD FILE"
git add "$TARGET"

echo
echo "[2] COMMIT"
git commit -m "phase487: preserve surgical guidance merge helper for index recovery" || true

echo
echo "[3] PUSH"
git push origin HEAD

echo
echo "===== DONE ====="
git log --oneline -n 3
