#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE88_7_SYSTEM_HEALTH_JS_ROUTE_SMOKE_EVIDENCE.txt"

{
  echo "PHASE 88.7 SYSTEM HEALTH JS ROUTE SMOKE EVIDENCE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "────────────────────────────────"

  npx tsx routes/diagnostics/systemHealth.js.route.smoke.ts

  echo "RESULT: PASS"
} | tee "$OUTPUT_FILE"
