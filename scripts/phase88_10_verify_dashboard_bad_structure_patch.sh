#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE88_10_DASHBOARD_BAD_STRUCTURE_PATCH_EVIDENCE.txt"

{
  echo "PHASE 88.10 DASHBOARD BAD STRUCTURE PATCH EVIDENCE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "────────────────────────────────"

  echo "SECTION: updatePanel block"
  sed -n '192,230p' public/dashboard.html.bad_structure

  echo "────────────────────────────────"
  echo "SECTION: system health target"
  rg -n "system-health-content|situationSummary|SITUATION SUMMARY" public/dashboard.html.bad_structure
} | tee "$OUTPUT_FILE"
