#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE88_12_SERVED_DASHBOARD_DIAGNOSTICS_SURFACE.txt"
TARGET="public/dashboard.html"

{
  echo "PHASE 88.12 SERVED DASHBOARD DIAGNOSTICS SURFACE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "Target: $TARGET"
  echo "────────────────────────────────"

  if [[ ! -f "$TARGET" ]]; then
    echo "ERROR: target file not found"
    exit 1
  fi

  echo "SECTION: KEY HITS"
  if command -v rg >/dev/null 2>&1; then
    rg -n 'diagnostic|diagnostics|system-health|health|status|panel|updatePanel|fetch\(' "$TARGET" || true
  else
    grep -nE 'diagnostic|diagnostics|system-health|health|status|panel|updatePanel|fetch\(' "$TARGET" || true
  fi
  echo "────────────────────────────────"

  echo "SECTION: FILE HEAD"
  sed -n '1,240p' "$TARGET"
  echo "────────────────────────────────"

  echo "SECTION: FILE MID"
  sed -n '241,520p' "$TARGET"
  echo "────────────────────────────────"

  echo "SECTION: FILE TAIL"
  sed -n '521,860p' "$TARGET"
  echo "────────────────────────────────"
} | tee "$OUTPUT_FILE"
