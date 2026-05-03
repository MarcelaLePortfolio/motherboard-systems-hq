#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/SERVED_INDEX_LAYOUT_HISTORY.txt"
TARGET="public/index.html"

COMMITS=(
  63600e77
  c368ed05
  368fdfbe
  ecac1fb1
  33f5c0e2
)

{
  echo "SERVED INDEX LAYOUT HISTORY"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo "Target: $TARGET"
  echo

  echo "=== CURRENT HISTORY ==="
  git log --oneline -- "$TARGET" | head -n 30
  echo

  for c in "${COMMITS[@]}"; do
    echo "================================================================"
    echo "COMMIT: $c"
    echo "================================================================"
    git show --stat --oneline --no-patch "$c" || true
    echo
    echo "--- KEY LAYOUT MARKERS ---"
    git show "$c:$TARGET" 2>/dev/null | grep -nE 'Operator Tools|operator-tools-grid|Matilda Chat Console|Activity Panels|Subsystem Status|Atlas Subsystem Status|grid|xl:grid-cols-2|Recent Tasks|Task History|Task Events|Delegation' | head -n 200 || true
    echo
    echo "--- FIRST 260 LINES ---"
    git show "$c:$TARGET" 2>/dev/null | sed -n '1,260p' || true
    echo
  done
} > "$OUT"

sed -n '1,260p' "$OUT"
