#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE87_17_SYSTEM_SUMMARY_CLI_SMOKE_EVIDENCE.txt"

{
  echo "PHASE 87.17 SYSTEM SUMMARY CLI SMOKE EVIDENCE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "────────────────────────────────"

  npx tsx src/cognition/systemSituationSummaryCli.smoke.ts

  echo "RESULT: PASS"
} | tee "$OUTPUT_FILE"
