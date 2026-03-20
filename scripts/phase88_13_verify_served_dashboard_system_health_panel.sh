#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE88_13_SERVED_DASHBOARD_SYSTEM_HEALTH_PANEL_EVIDENCE.txt"

{
  echo "PHASE 88.13 SERVED DASHBOARD SYSTEM HEALTH PANEL EVIDENCE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "────────────────────────────────"

  echo "SECTION: panel hits"
  rg -n "system-health-content|System Health Diagnostics|SITUATION SUMMARY|/diagnostics/system-health" public/dashboard.html

  echo "────────────────────────────────"
  echo "SECTION: panel slice"
  sed -n '430,520p' public/dashboard.html

  echo "────────────────────────────────"
  echo "SECTION: script slice"
  sed -n '620,760p' public/dashboard.html
} | tee "$OUTPUT_FILE"
