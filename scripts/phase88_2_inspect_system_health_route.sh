#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE88_2_SYSTEM_HEALTH_ROUTE_INSPECTION.txt"
TARGET="routes/diagnostics/systemHealth.ts"

{
  echo "PHASE 88.2 SYSTEM HEALTH ROUTE INSPECTION"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "Target: $TARGET"
  echo "────────────────────────────────"

  if [[ ! -f "$TARGET" ]]; then
    echo "ERROR: target file not found"
    exit 1
  fi

  echo "SECTION: FILE HEAD (first 220 lines)"
  sed -n '1,220p' "$TARGET"
  echo "────────────────────────────────"

  echo "SECTION: EXPORTED SYMBOLS"
  if command -v rg >/dev/null 2>&1; then
    rg -n 'export|module\.exports|router|app\.get|app\.post|res\.json|return' "$TARGET" || true
  else
    grep -nE 'export|module\.exports|router|app\.get|app\.post|res\.json|return' "$TARGET" || true
  fi
  echo "────────────────────────────────"

  echo "SECTION: SITUATION SUMMARY ATTACHMENT HELPER"
  sed -n '1,220p' routes/diagnostics/systemHealthSituationSummary.ts
  echo "────────────────────────────────"

  echo "NEXT ACTION"
  echo "Use this inspection to patch routes/diagnostics/systemHealth.ts with the narrowest possible read-only situationSummary attachment."
} | tee "$OUTPUT_FILE"
