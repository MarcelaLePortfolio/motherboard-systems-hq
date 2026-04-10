#!/usr/bin/env bash
set -euo pipefail

DOC="docs/phase464_x_system_health_route_candidates.txt"
OUT="docs/phase464_x_authoritative_route_target.txt"

echo "PHASE 464.X — AUTHORITATIVE ROUTE TARGETING"
echo "==========================================="
echo

if [ ! -f "$DOC" ]; then
  echo "ERROR: expected artifact not found: $DOC"
  exit 1
fi

echo "STEP 1 — Extract candidate files"
FILES=$(grep "^FILE:" "$DOC" | sed 's/^FILE: //')

if [ -z "$FILES" ]; then
  echo "ERROR: no candidate files found in artifact"
  exit 1
fi

echo "Candidates:"
echo "$FILES"
echo

echo "STEP 2 — Score files by relevance"

BEST_FILE=""
BEST_SCORE=0

for f in $FILES; do
  SCORE=$(rg -c 'res\.json|res\.send|SYSTEM_HEALTH|systemHealth|router\.get' "$f" || echo 0)
  echo "$f → score: $SCORE"
  if [ "$SCORE" -gt "$BEST_SCORE" ]; then
    BEST_SCORE=$SCORE
    BEST_FILE="$f"
  fi
done

echo
echo "Selected authoritative candidate: $BEST_FILE (score $BEST_SCORE)"

if [ -z "$BEST_FILE" ]; then
  echo "ERROR: could not determine authoritative file"
  exit 1
fi

echo
echo "STEP 3 — Extract payload construction zone"

{
  echo "AUTHORITATIVE FILE: $BEST_FILE"
  echo "----------------------------------------"
  echo
  rg -n 'res\.json|res\.send' "$BEST_FILE" || true
  echo
  sed -n '1,220p' "$BEST_FILE"
} > "$OUT"

echo "Wrote $OUT"

echo
echo "STEP 4 — OPEN THIS FILE NEXT:"
echo "$OUT"

