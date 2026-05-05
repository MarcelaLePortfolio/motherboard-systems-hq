#!/usr/bin/env bash
set -euo pipefail

echo "Committing blocker reader script..."

git add PHASE702_STEP5H_READ_VERIFY_BLOCKER.sh
git commit -m "Phase 702: add replay blocker reader"
git push

echo
echo "Inspecting replay violation exports..."

sed -n '1,220p' src/governance_investigation/verification/replay_violation_codes.ts
echo
sed -n '1,120p' src/governance_investigation/verification/check-pathological-fixtures.ts
echo
sed -n '1,120p' scripts/_local/verification/check-replay-diagnostic-codes.ts

git status --short
