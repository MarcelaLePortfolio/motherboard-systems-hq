#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
IN="$ROOT/docs/PHASE_487_STEP1_DASHBOARD_ENTRYPOINT.txt"
OUT="$ROOT/docs/PHASE_487_STEP1_RENDER_BOUNDARY_CANDIDATES.txt"

{
  echo "PHASE 487 — STEP 1 RENDER BOUNDARY CANDIDATES"
  echo
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Source: $IN"
  echo
  echo "────────────────────────────────"
  echo "TOP CANDIDATE FILES"
  echo "────────────────────────────────"
  grep -E '(^.*/app/.*page\.(tsx|jsx)$)|(^.*/pages/.*\.(tsx|jsx|ts|js)$)|(^.*/.*(dashboard|operator|workspace|console|telemetry|approval|governance|execution|trace).*\.(tsx|jsx|ts|js)$)' "$IN" \
    | grep -v 'PHASE_487_STEP1_DASHBOARD_ENTRYPOINT.txt' \
    | awk '!seen[$0]++' \
    | sed '/^[[:space:]]*$/d'
  echo
  echo "────────────────────────────────"
  echo "PRIORITY SHORTLIST"
  echo "────────────────────────────────"
  grep -E '(^.*/app/.*page\.(tsx|jsx)$)|(^.*/pages/.*\.(tsx|jsx|ts|js)$)|(^.*/.*(dashboard|operator|workspace|console|telemetry|approval|governance|execution|trace).*\.(tsx|jsx|ts|js)$)' "$IN" \
    | grep -Ei '(dashboard|operator|workspace|console|matilda|telemetry|approval|governance|execution|trace|app/.*/page|pages/)' \
    | grep -v 'PHASE_487_STEP1_DASHBOARD_ENTRYPOINT.txt' \
    | awk '!seen[$0]++' \
    | sed '/^[[:space:]]*$/d' \
    | head -n 25
  echo
  echo "────────────────────────────────"
  echo "NEXT ACTION"
  echo "────────────────────────────────"
  echo "Inspect the highest-confidence UI route/component files above and choose the smallest render boundary that only groups existing sections without touching hooks, data, or contracts."
} > "$OUT"

echo "Wrote $OUT"
