#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_confidence_fix_commit_and_restart_${STAMP}.txt"

{
  echo "PHASE 487 — CONFIDENCE FIX COMMIT + RESTART"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit_before=$(git rev-parse HEAD)"
  echo

  echo "=== TARGET DIFF ==="
  git diff -- src/cognition/operatorGuidanceConfidence.ts || true
  echo

  echo "=== SOURCE CHECK ==="
  rg -n -C 3 "insufficient|limited|confidence" src/cognition/operatorGuidanceConfidence.ts || true
  echo

  echo "=== INTENT ==="
  echo "Commit the already-modified confidence mapping file and restart the local dashboard/runtime so the UI reflects the change."
  echo
} > "${OUT}"

echo "${OUT}"
