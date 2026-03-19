#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE88_9_DASHBOARD_SYSTEM_HEALTH_CONSUMER_INSPECTION.txt"

{
  echo "PHASE 88.9 DASHBOARD SYSTEM HEALTH CONSUMER INSPECTION"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "Repo: $(pwd)"
  echo "────────────────────────────────"

  echo "SECTION: public/dashboard.html hits"
  if [[ -f "public/dashboard.html" ]]; then
    if command -v rg >/dev/null 2>&1; then
      rg -n 'system-health-content|/diagnostics/system-health|updatePanel|diagnosticsSection' public/dashboard.html || true
    else
      grep -nE 'system-health-content|/diagnostics/system-health|updatePanel|diagnosticsSection' public/dashboard.html || true
    fi
    echo "────────────────────────────────"
    echo "SECTION: public/dashboard.html relevant slice"
    sed -n '140,260p' public/dashboard.html
  else
    echo "public/dashboard.html not found"
  fi
  echo "────────────────────────────────"

  echo "SECTION: backup dashboard candidates"
  for target in \
    public/dashboard.html.bad_structure \
    public/dashboard.html.bak \
    public/dashboard.pre-bundle-tag.html
  do
    if [[ -f "$target" ]]; then
      echo "FILE: $target"
      if command -v rg >/dev/null 2>&1; then
        rg -n 'system-health-content|/diagnostics/system-health|updatePanel|diagnosticsSection' "$target" || true
      else
        grep -nE 'system-health-content|/diagnostics/system-health|updatePanel|diagnosticsSection' "$target" || true
      fi
      echo "────────────────────────────────"
    fi
  done
} | tee "$OUTPUT_FILE"
