#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs
OUT="docs/phase464_x_phase456_baseline_emitter_candidates.txt"

{
  echo "PHASE 464.X — PHASE456 BASELINE EMITTER CANDIDATES"
  echo "=================================================="
  echo
  echo "Timestamp (UTC): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo root: $(pwd)"
  echo

  echo "1) Exact phase456 / baseline / guidance anchors"
  rg -n 'Phase 456|PHASE 456|phase456|baseline emitter|operator guidance|Operator Guidance|SYSTEM_HEALTH|No active tasks|Awaiting operator input|guidance is now controlled|controlled ONLY by Phase 456 baseline emitter' \
    public js src app . \
    --glob '!node_modules' --glob '!.git' 2>/dev/null || true
  echo

  echo "2) Browser-adjacent candidate files"
  find public js src app . -type f \( -iname '*.js' -o -iname '*.ts' -o -iname '*.tsx' -o -iname '*.mjs' \) 2>/dev/null \
    | sed 's#^\./##' \
    | grep -Ev 'node_modules|\.git|docs/|scripts/' \
    | grep -Ei 'guidance|operator|phase456|baseline|status|dashboard|health|atlas|matilda|delegation' \
    | sort -u || true
  echo

  echo "3) Focused excerpts from exact matches"
  while IFS=: read -r file line _; do
    [ -f "$file" ] || continue
    start=$(( line > 20 ? line - 20 : 1 ))
    end=$(( line + 50 ))
    echo "FILE: $file"
    echo "----- lines ${start}-${end} -----"
    sed -n "${start},${end}p" "$file"
    echo
  done < <(
    rg -n 'Phase 456|PHASE 456|phase456|baseline emitter|operator guidance|Operator Guidance|SYSTEM_HEALTH|No active tasks|Awaiting operator input|guidance is now controlled|controlled ONLY by Phase 456 baseline emitter' \
      public js src app . \
      --glob '!node_modules' --glob '!.git' 2>/dev/null \
    | awk -F: '!seen[$1":"$2]++' \
    | head -n 30
  )

  echo "4) Ranked likely next targets"
  rg -l 'Phase 456|PHASE 456|phase456|baseline emitter|operator guidance|Operator Guidance|SYSTEM_HEALTH|No active tasks|Awaiting operator input' \
    public js src app . \
    --glob '!node_modules' --glob '!.git' 2>/dev/null \
  | sed 's#^\./##' \
  | awk '
      {
        score=100
        if ($0 ~ /public\//) score-=30
        if ($0 ~ /guidance|operator|phase456|baseline/) score-=25
        if ($0 ~ /dashboard|status|health/) score-=10
        if ($0 ~ /docs\//) score+=100
        if ($0 ~ /scripts\//) score+=50
        print score " " $0
      }
    ' \
  | sort -n -k1,1 -k2,2 \
  | awk '!seen[$2]++' \
  | head -n 20
  echo

  echo "5) Decision gate"
  echo "- If a single browser file references Phase 456 baseline guidance ownership, that becomes the next proof target."
  echo "- If only comments reference Phase 456, expand to actual loaded sourcemap module names next."
} > "$OUT"

echo "Wrote $OUT"
