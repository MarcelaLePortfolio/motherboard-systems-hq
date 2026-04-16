#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_post_force_confidence_check_${STAMP}.txt"

{
  echo "PHASE 487 — POST FORCE CONFIDENCE CHECK"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== ROUTE SOURCE CHECK ==="
  rg -n -C 4 "surfaceConfidence|confidence|limited|insufficient|diagnostics/system-health" routes/diagnostics/operatorGuidanceRuntime.js 2>/dev/null || true
  echo

  echo "=== PM2 STATUS ==="
  pm2 list 2>&1 || true
  echo

  echo "=== HTTP CHECK ==="
  curl -I --max-time 5 http://localhost:3000 2>&1 || echo "localhost:3000 unreachable"
  curl -I --max-time 5 http://localhost:8080 2>&1 || echo "localhost:8080 unreachable"
  echo

  echo "=== FINAL READ ==="
  echo "Refresh the dashboard now and verify whether Operator Guidance shows Confidence: limited."
  echo
} > "${OUT}"

echo "${OUT}"
