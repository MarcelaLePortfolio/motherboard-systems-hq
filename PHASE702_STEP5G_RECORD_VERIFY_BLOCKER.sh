#!/usr/bin/env bash
set -euo pipefail

REPORT="docs/phase702-validation-blocker-replay-verify.md"

{
  echo "# Phase 702 Validation Blocker — Replay Verify"
  echo
  echo "Generated: $(date)"
  echo
  echo "## Observed Failure"
  echo
  echo "\`npm run verify:replay\` fails before completing because \`normalizeViolations\` is not available as a function."
  echo
  echo "## Failure Classification"
  echo
  echo "- Validation blocker"
  echo "- Not evidence that the Phase 702 UI-only status reasoning patch failed"
  echo "- Located in governance replay diagnostics path"
  echo
  echo "## Stack Location"
  echo
  echo "- src/governance_investigation/verification/replay_fixture_diagnostics.ts"
  echo "- scripts/_local/verification/check-replay-verification.ts"
  echo
  echo "## Relevant File Inspection"
  echo
  echo "### replay_fixture_diagnostics.ts"
  echo '```ts'
  sed -n '1,140p' src/governance_investigation/verification/replay_fixture_diagnostics.ts || true
  echo '```'
  echo
  echo "### replay_violation_codes references"
  echo '```'
  grep -RIn "normalizeViolations\\|replay_violation_codes" src scripts 2>/dev/null || true
  echo '```'
  echo
  echo "## Safe Next Step"
  echo
  echo "Inspect export/import mismatch before making any patch. Do not layer speculative fixes."
} > "$REPORT"

git add PHASE702_STEP5F_RUN_AVAILABLE_VERIFY.sh PHASE702_STEP5G_RECORD_VERIFY_BLOCKER.sh "$REPORT"
git commit -m "Phase 702: record replay verification blocker"
git push

git status --short
