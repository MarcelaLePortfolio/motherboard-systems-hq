#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs
OUT="docs/phase464_x_bundle_guidance_owner_scan.txt"

{
  echo "PHASE 464.X — BUNDLE GUIDANCE OWNER SCAN"
  echo "========================================"
  echo
  echo "Timestamp (UTC): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo root: $(pwd)"
  echo

  echo "1) Exact operator guidance / system health anchors in bundle.js"
  rg -n 'operator-guidance|Operator Guidance|SYSTEM_HEALTH|system health|Awaiting bounded guidance stream|diagnostics/system-health|guidance|atlas-status|Atlas Subsystem Status' bundle.js 2>/dev/null || true
  echo

  echo "2) DOM write anchors in bundle.js"
  rg -n 'textContent|innerHTML|appendChild|append\\(|insertAdjacent|replaceChildren|MutationObserver' bundle.js 2>/dev/null | head -n 400 || true
  echo

  echo "3) Lifecycle / reconnect / interval anchors in bundle.js"
  rg -n 'EventSource|WebSocket|setInterval|clearInterval|visibilitychange|focus|blur|pageshow|pagehide|DOMContentLoaded|beforeunload' bundle.js 2>/dev/null | head -n 400 || true
  echo

  echo "4) Focused excerpts around exact guidance/system health anchors"
  while IFS=: read -r line _; do
    start=$(( line > 20 ? line - 20 : 1 ))
    end=$(( line + 40 ))
    echo "----- bundle.js lines ${start}-${end} -----"
    sed -n "${start},${end}p" bundle.js
    echo
  done < <(rg -n 'operator-guidance|Operator Guidance|SYSTEM_HEALTH|system health|Awaiting bounded guidance stream|diagnostics/system-health|atlas-status|Atlas Subsystem Status' bundle.js 2>/dev/null | cut -d: -f1 | awk '!seen[$0]++' | head -n 30)
  echo

  echo "5) Ranked likely bundle-adjacent source files"
  find public/js src app . -type f \( -iname '*.js' -o -iname '*.ts' -o -iname '*.tsx' -o -iname '*.mjs' \) 2>/dev/null \
    | sed 's#^\./##' \
    | grep -Ev 'node_modules|\.git|docs/|scripts/' \
    | grep -Ei 'guidance|dashboard|status|matilda|operator|health|atlas|delegation|task-events|sse' \
    | sort | head -n 200
  echo

  echo "DECISION GATE:"
  echo "- If bundle.js contains direct guidance/system-health rendering, next mutation target is bundle source ownership."
  echo "- If bundle.js only references supporting widgets, identify the upstream source file feeding bundle build."
} > "$OUT"

echo "Wrote $OUT"
