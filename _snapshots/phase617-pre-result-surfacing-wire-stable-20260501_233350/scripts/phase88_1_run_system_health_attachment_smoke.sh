#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE88_1_SYSTEM_HEALTH_ATTACHMENT_SMOKE_EVIDENCE.txt"

{
  echo "PHASE 88.1 SYSTEM HEALTH ATTACHMENT SMOKE EVIDENCE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "────────────────────────────────"

  npx tsx routes/diagnostics/systemHealthSituationSummary.smoke.ts

  echo "RESULT: PASS"
} | tee "$OUTPUT_FILE"
