#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_verify_served_confidence_after_exact_patch_${STAMP}.txt"
SNAP="docs/phase487_verify_served_confidence_after_exact_patch_${STAMP}.html"

curl -s http://localhost:8080 > "${SNAP}"

{
  echo "PHASE 487 — VERIFY SERVED CONFIDENCE AFTER EXACT PATCH"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== HTTP CHECK ==="
  curl -I --max-time 5 http://localhost:8080 2>&1 || echo "localhost:8080 unreachable"
  echo

  echo "=== SERVED BODY CHECK ==="
  grep -n -C 3 "Confidence: limited\|Confidence: insufficient\|Awaiting bounded guidance stream\|Live operator guidance will appear here when visibility wiring is active\|Sources: diagnostics/system-health" "${SNAP}" || true
  echo

  echo "=== VERDICT ==="
  if grep -q "Confidence: limited" "${SNAP}"; then
    echo "served_body_contains_confidence_limited=YES"
  else
    echo "served_body_contains_confidence_limited=NO"
  fi

  if grep -q "Confidence: insufficient" "${SNAP}"; then
    echo "served_body_contains_confidence_insufficient=YES"
  else
    echo "served_body_contains_confidence_insufficient=NO"
  fi
  echo
} > "${OUT}"

echo "${OUT}"
echo "${SNAP}"
