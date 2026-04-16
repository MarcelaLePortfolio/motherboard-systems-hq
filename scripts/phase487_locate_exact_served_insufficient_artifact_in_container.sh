#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_locate_exact_served_insufficient_artifact_in_container_${STAMP}.txt"

CONTAINER_ID="$(docker ps --format '{{.ID}} {{.Ports}} {{.Names}}' 2>/dev/null | awk '/0\.0\.0\.0:8080->|:::8080->/ {print $1; exit}')"
CONTAINER_NAME="$(docker ps --format '{{.ID}} {{.Names}}' 2>/dev/null | awk -v id="${CONTAINER_ID}" '$1==id {print $2; exit}')"

if [ -z "${CONTAINER_ID:-}" ]; then
  echo "No container currently serving port 8080."
  exit 1
fi

{
  echo "PHASE 487 — LOCATE EXACT SERVED INSUFFICIENT ARTIFACT IN CONTAINER"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo "container_id=${CONTAINER_ID}"
  echo "container_name=${CONTAINER_NAME:-UNKNOWN}"
  echo

  echo "=== SERVED HTML SNAPSHOT CHECK ==="
  curl -s http://localhost:8080 | grep -n -C 3 "Awaiting bounded guidance stream\|Live operator guidance will appear here when visibility wiring is active\|Confidence: insufficient\|Confidence: limited\|Sources: diagnostics/system-health" || true
  echo

  echo "=== CONTAINER: EXACT STRING SEARCH UNDER /app ==="
  docker exec "${CONTAINER_ID}" sh -lc '
    find /app \
      \( -path /app/node_modules -o -path /app/.git -o -path /app/.next/cache \) -prune -o \
      -type f \
      \( -name "*.html" -o -name "*.js" -o -name "*.mjs" -o -name "*.cjs" -o -name "*.ts" -o -name "*.tsx" -o -name "*.json" \) \
      -print 2>/dev/null \
    | while IFS= read -r f; do
        grep -n -C 3 "Awaiting bounded guidance stream\|Live operator guidance will appear here when visibility wiring is active\|Confidence: insufficient\|Confidence: limited\|Sources: diagnostics/system-health" "$f" 2>/dev/null && echo "FILE_HIT:$f"
      done
  ' || true
  echo

  echo "=== CONTAINER: FILES CONTAINING Confidence: insufficient ==="
  docker exec "${CONTAINER_ID}" sh -lc '
    find /app \
      \( -path /app/node_modules -o -path /app/.git -o -path /app/.next/cache \) -prune -o \
      -type f \
      \( -name "*.html" -o -name "*.js" -o -name "*.mjs" -o -name "*.cjs" -o -name "*.ts" -o -name "*.tsx" -o -name "*.json" \) \
      -print 2>/dev/null \
    | xargs grep -n -l "Confidence: insufficient" 2>/dev/null | sort -u
  ' || true
  echo

  echo "=== CONTAINER: POSSIBLE DASHBOARD ENTRY FILES ==="
  docker exec "${CONTAINER_ID}" sh -lc '
    find /app \
      \( -path /app/node_modules -o -path /app/.git \) -prune -o \
      -type f \
      \( -name "server.*" -o -name "*.js" -o -name "*.mjs" -o -name "*.cjs" -o -name "*.ts" \) \
      -print 2>/dev/null \
    | xargs grep -n -E "sendFile\\(|express\\.static|dashboard\\.html|listen\\(3000|listen\\(8080|process\\.env\\.PORT|/dashboard" 2>/dev/null | head -n 300
  ' || true
  echo

  echo "=== CONTAINER: TOP-LEVEL /app LAYOUT ==="
  docker exec "${CONTAINER_ID}" sh -lc 'find /app -maxdepth 2 -type f | sort | head -n 300' || true
  echo

  echo "=== NEXT ACTION ==="
  echo "Patch the exact container-served artifact file that still contains Confidence: insufficient."
  echo
} > "${OUT}"

echo "${OUT}"
