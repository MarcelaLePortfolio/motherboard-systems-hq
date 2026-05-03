#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE88_11_DASHBOARD_ENTRYPOINT_INSPECTION.txt"

{
  echo "PHASE 88.11 DASHBOARD ENTRYPOINT INSPECTION"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "Repo: $(pwd)"
  echo "────────────────────────────────"

  echo "SECTION: server.mjs dashboard/static references"
  if [[ -f server.mjs ]]; then
    rg -n 'dashboard\.html|bad_structure|pre-bundle|express\.static|sendFile|public' server.mjs || true
    echo "────────────────────────────────"
    sed -n '150,220p' server.mjs
    echo "────────────────────────────────"
    sed -n '220,360p' server.mjs
  else
    echo "server.mjs not found"
  fi

  echo "────────────────────────────────"
  echo "SECTION: public dashboard candidate files"
  ls -l public/dashboard* 2>/dev/null || true

  echo "────────────────────────────────"
  echo "SECTION: bad_structure system health panel evidence"
  rg -n 'system-health-content|SITUATION SUMMARY|situationSummary' public/dashboard.html.bad_structure 2>/dev/null || true

  echo "────────────────────────────────"
  echo "NEXT ACTION"
  echo "Identify which dashboard file is actually served before widening UI attachment."
} | tee "$OUTPUT_FILE"
