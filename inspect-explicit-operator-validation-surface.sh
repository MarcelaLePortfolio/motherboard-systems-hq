#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="9d3a5df91"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== AUTHORIZED INSPECTION BOUNDARY ===\n'
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "CURRENT_STEP=INSPECTION_ONLY"
echo "LIVE_VALIDATION_INVOCATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "AUTO_ADVANCE=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== APPROVALS WORKSPACE VALIDATION / DELEGATION SURFACE ===\n'
grep -nE \
  'delegat|validat|canonical|package|button|fetch|api/' \
  client/src/approvals/ApprovalsWorkspace.tsx \
  | head -n 260 || true

printf '\n=== CLIENT API / GOVERNANCE REFERENCES ===\n'
grep -RniE \
  'governance-validation|validation_result|delegation_id|/api/.+validation|delegate' \
  client/src \
  --exclude-dir=node_modules \
  | head -n 320 || true

printf '\n=== PRODUCTION VALIDATION ROUTE ===\n'
sed -n '1,260p' server/routes/governance-validation-route.ts

printf '\n=== VALIDATION CONSUMER ===\n'
sed -n '1,280p' server/validation/production-validation-consumer.ts

printf '\n=== VALIDATION ROUTE MOUNT REFERENCES ===\n'
grep -RniE \
  'governance-validation-route|governanceValidation|governance-validation' \
  server \
  --exclude='*.test.ts' \
  --exclude-dir=node_modules \
  | head -n 240 || true

printf '\n=== APPROVALS API MODULES ===\n'
find client/src -maxdepth 4 -type f \
  \( -iname '*approval*' -o -iname '*governance*' -o -iname '*delegat*' -o -iname '*validation*' \) \
  -print | sort

printf '\n=== WORKTREE PRESERVATION ===\n'
git status --short

printf '\nEXPLICIT_OPERATOR_VALIDATION_SURFACE_INSPECTION=COMPLETE\n'
