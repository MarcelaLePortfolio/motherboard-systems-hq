#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE87_3_INTEGRATION_SMOKE_EVIDENCE.txt"

{
  echo "PHASE 87.3 INTEGRATION SMOKE EVIDENCE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "────────────────────────────────"
  npx tsx src/cognition/situationSummaryIntegration.smoke.ts
} | tee "$OUTPUT_FILE"
