#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs
OUT="docs/phase464_x_dashboard_status_hotspots.txt"
FILE="public/js/dashboard-status.js"

{
  echo "PHASE 464.X — DASHBOARD STATUS HOTSPOTS"
  echo "======================================="
  echo
  echo "Timestamp (UTC): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo root: $(pwd)"
  echo "Target: $FILE"
  echo

  echo "1) Exact hit lines"
  rg -n 'EventSource|setInterval|appendChild|append\(|textContent|replaceChildren|innerHTML|ops|reflections|state|update|patch|delta' "$FILE" || true
  echo

  echo "2) Full file header"
  sed -n '1,220p' "$FILE"
  echo

  echo "3) Focused excerpts around connect() and event handling"
  while IFS=: read -r line _; do
    start=$(( line > 25 ? line - 25 : 1 ))
    end=$(( line + 55 ))
    echo "----- $FILE lines ${start}-${end} -----"
    sed -n "${start},${end}p" "$FILE"
    echo
  done < <(rg -n 'function connect|const handle =|es.onmessage|addEventListener|window.dispatchEvent|setInterval' "$FILE" | cut -d: -f1 | awk '!seen[$0]++')
  echo

  echo "4) Decision gate"
  echo "- If connect()/handle()/tick() are only indicator updates, dashboard-status.js is a false positive."
  echo "- If it appends/grows visible content outside indicators, it becomes the single-file fix target."
} > "$OUT"

echo "Wrote $OUT"
