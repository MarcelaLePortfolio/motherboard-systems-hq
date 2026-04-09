#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs

OUT="docs/phase464_x_dashboard_script_duplicate_scan.txt"

{
  echo "PHASE 464.X — DASHBOARD SCRIPT DUPLICATE SCAN"
  echo "============================================="
  echo
  echo "Timestamp (UTC): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo root: $(pwd)"
  echo

  echo "1) All script src references in public/dashboard.html"
  perl -ne 'while (/<script[^>]+src=["'"'"']([^"'"'"']+)["'"'"'][^>]*>/g) { print "$1\n" }' public/dashboard.html 2>/dev/null || true
  echo

  echo "2) Duplicate script src references with counts"
  perl -ne 'while (/<script[^>]+src=["'"'"']([^"'"'"']+)["'"'"'][^>]*>/g) { print "$1\n" }' public/dashboard.html 2>/dev/null \
    | sort | uniq -c | sort -nr || true
  echo

  echo "3) Inline script blocks with line numbers"
  awk '
    /<script/ { in_script=1; start=NR }
    in_script { print NR ":" $0 }
    /<\/script>/ && in_script { print ""; in_script=0 }
  ' public/dashboard.html 2>/dev/null | head -n 1200 || true
  echo

  echo "4) Focused script-tag excerpt around operator workspace and Atlas section"
  sed -n '620,860p' public/dashboard.html 2>/dev/null || true
  echo

  echo "5) Decision gate"
  echo "- If duplicate browser scripts are loaded, fix target becomes public/dashboard.html only."
  echo "- If no duplicates exist, return to client producer isolation with exact loaded script order."
} > "$OUT"

echo "Wrote $OUT"
