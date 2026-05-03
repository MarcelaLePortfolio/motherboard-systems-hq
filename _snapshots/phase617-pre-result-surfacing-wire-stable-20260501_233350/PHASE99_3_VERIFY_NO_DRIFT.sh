#!/usr/bin/env bash
set -euo pipefail

run_smoke() {
  local file="$1"

  echo "Running $file ..."
  if command -v pnpm >/dev/null 2>&1; then
    pnpm exec tsx "$file"
  else
    npx tsx "$file"
  fi
  echo
}

echo "Phase 99.3 — Behavioral drift verification"
echo

run_smoke "src/cognition/situationSummaryIntegration.smoke.ts"
run_smoke "src/cognition/situationSummaryRender.smoke.ts"
run_smoke "src/cognition/getSituationSummarySnapshot.smoke.ts"
run_smoke "src/cognition/governanceCognition.smoke.ts"
run_smoke "src/cognition/index.smoke.ts"

echo "Phase 99.3 verification run complete."
