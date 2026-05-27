#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE87_1_SMOKE_EVIDENCE.txt"

{
  echo "PHASE 87.1 SMOKE EVIDENCE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "────────────────────────────────"
  npx tsx scripts/phase87_1_situation_summary_smoke.ts
} | tee "$OUTPUT_FILE"
