#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_confidence_render_surface_${STAMP}.txt"

SEARCH_DIRS=()
for dir in app src ui lib pages; do
  if [ -d "$dir" ]; then
    SEARCH_DIRS+=("$dir")
  fi
done

if [ "${#SEARCH_DIRS[@]}" -eq 0 ]; then
  SEARCH_DIRS=(.)
fi

{
  echo "PHASE 487 — CONFIDENCE RENDER SURFACE TRACE"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo "search_dirs=${SEARCH_DIRS[*]}"
  echo

  echo "=== SEARCH: literal insufficient ==="
  rg -n -C 2 -m 120 "insufficient|Confidence: insufficient|confidence.*insufficient" "${SEARCH_DIRS[@]}" \
    --glob '!.git' \
    --glob '!node_modules' \
    --glob '!.next' \
    --glob '!dist' \
    --glob '!coverage' || true
  echo

  echo "=== SEARCH: operator guidance confidence render ==="
  rg -n -C 2 -m 160 "Confidence:|confidenceLabel|confidence|operator guidance|Operator Guidance" "${SEARCH_DIRS[@]}" \
    --glob '!.git' \
    --glob '!node_modules' \
    --glob '!.next' \
    --glob '!dist' \
    --glob '!coverage' || true
  echo

  echo "=== SEARCH: diagnostics/system-health source path ==="
  rg -n -C 2 -m 120 "diagnostics/system-health|system-health|system_health" "${SEARCH_DIRS[@]}" \
    --glob '!.git' \
    --glob '!node_modules' \
    --glob '!.next' \
    --glob '!dist' \
    --glob '!coverage' || true
  echo

  echo "=== SEARCH: limited label propagation ==="
  rg -n -C 2 -m 120 "limited|confidence.*limited" "${SEARCH_DIRS[@]}" \
    --glob '!.git' \
    --glob '!node_modules' \
    --glob '!.next' \
    --glob '!dist' \
    --glob '!coverage' || true
  echo

  echo "=== FINAL READ ==="
  echo "Goal: identify the actual render surface still emitting insufficient."
  echo "Likely classes:"
  echo "1. third display-layer mapping"
  echo "2. stale derived enum-to-label formatter"
  echo "3. diagnostics/system-health direct confidence source bypassing prior patch"
  echo
} > "${OUT}"

echo "${OUT}"
