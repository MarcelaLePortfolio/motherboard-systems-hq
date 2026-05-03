#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_post_container_patch_verification_${STAMP}.txt"

{
  echo "PHASE 487 — POST CONTAINER PATCH VERIFICATION"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== HTTP CHECK ==="
  curl -I --max-time 5 http://localhost:8080 2>&1 || echo "localhost:8080 unreachable"
  echo

  echo "=== SERVED BODY CHECK ==="
  curl -s http://localhost:8080 | grep -n -C 3 "Confidence: limited\|Confidence: insufficient\|Awaiting bounded guidance stream\|Live operator guidance will appear here when visibility wiring is active\|Sources: diagnostics/system-health" || true
  echo

  echo "=== FINAL READ ==="
  echo "Refresh the dashboard now."
  echo "If the UI still shows Confidence: insufficient while served body shows Confidence: limited,"
  echo "the remaining issue is browser-side cache/runtime state rather than the served artifact."
  echo
} > "${OUT}"

echo "${OUT}"
