#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs
SCAN="docs/phase464_x_bundle_guidance_owner_scan.txt"
OUT="docs/phase464_x_bundle_owner_shortlist.txt"

{
  echo "PHASE 464.X — BUNDLE OWNER SHORTLIST"
  echo "===================================="
  echo
  echo "Timestamp (UTC): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo root: $(pwd)"
  echo "Source scan: $SCAN"
  echo

  echo "1) Exact bundle guidance/system-health anchors"
  awk '
    /1\) Exact operator guidance \/ system health anchors in bundle\.js/ {flag=1; next}
    /2\) DOM write anchors in bundle\.js/ {flag=0}
    flag
  ' "$SCAN"
  echo

  echo "2) Bundle lifecycle/reconnect anchors"
  awk '
    /3\) Lifecycle \/ reconnect \/ interval anchors in bundle\.js/ {flag=1; next}
    /4\) Focused excerpts around exact guidance\/system health anchors/ {flag=0}
    flag
  ' "$SCAN"
  echo

  echo "3) Candidate source files"
  awk '
    /5\) Ranked likely bundle-adjacent source files/ {flag=1; next}
    /DECISION GATE:/ {flag=0}
    flag
  ' "$SCAN" | sed '/^$/d'
  echo

  echo "4) SHORTLIST (heuristic filter)"
  awk '
    /5\) Ranked likely bundle-adjacent source files/ {flag=1; next}
    /DECISION GATE:/ {flag=0}
    flag
  ' "$SCAN" \
  | sed '/^$/d' \
  | grep -Ei 'guidance|health|atlas|dashboard|status|sse|event' \
  | head -n 20
  echo

  echo "5) DECISION"
  echo "- If shortlist contains a guidance/status renderer file → NEXT TARGET = that single file"
  echo "- If shortlist is dominated by bundle-only artifacts → NEXT TARGET = upstream build source"
  echo
} > "$OUT"

echo "Wrote $OUT"
