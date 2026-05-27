#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE87_6_RENDER_SMOKE_EVIDENCE.txt"

{
  echo "PHASE 87.6 RENDER SMOKE EVIDENCE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "────────────────────────────────"
  npx tsx src/cognition/situationSummaryRender.smoke.ts
  echo "RESULT: PASS"
} | tee "$OUTPUT_FILE"
