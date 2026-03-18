#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE87_10_UNKNOWN_GETTER_SMOKE_EVIDENCE.txt"

{
  echo "PHASE 87.10 UNKNOWN GETTER SMOKE EVIDENCE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "────────────────────────────────"

  npx tsx src/cognition/getSituationSummary.unknown.smoke.ts

  echo "RESULT: PASS"
} | tee "$OUTPUT_FILE"
