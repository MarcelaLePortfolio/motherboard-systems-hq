#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="83293d5c5"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

BEFORE_UNSTAGED="$(git diff --name-only)"

printf '\n=== GOVERNANCE DELEGATION ROUTE ===\n'
sed -n '1,360p' server/routes/governance-delegation-route.ts

printf '\n=== DELEGATION PRODUCTION CONSUMER / ENTRY POINT ===\n'
for f in \
  server/delegation/production-delegation-consumer.ts \
  server/delegation/production-delegation-entry-point.ts \
  server/governance/production-delegation-consumer.ts \
  server/governance/production-delegation-entry-point.ts
do
  if [ -f "$f" ]; then
    echo
    echo "--- $f ---"
    sed -n '1,420p' "$f"
  fi
done

printf '\n=== ROUTE IMPORTS AND DIRECT DEPENDENCIES ===\n'
grep -nE \
  '^(import|export)|createGovernanceDelegation|consume|invoke|router\.(post|put|patch)|authorization|authorized|canonical|package|delegation' \
  server/routes/governance-delegation-route.ts || true

printf '\n=== EXACT ROUTE REGISTRATION ===\n'
grep -nE \
  'createGovernanceDelegationRouter|app\.use' \
  server/index.ts || true

printf '\n=== DELEGATION IMPLEMENTATION REFERENCES ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B20 -A70 \
  'createGovernanceDelegationRouter|handleGovernanceDelegation|consumeProductionDelegation|invokeProductionDelegation|createGovernanceDelegation\(' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== CLASSIFICATION ===\n'
echo 'CURRENT_OBJECTIVE=LIVE_END_TO_END_DELEGATED_TASK_VALIDATION'
echo 'REGISTERED_DELEGATION_ROUTER_CONFIRMED=YES'
echo 'REGISTERED_BY=server/index.ts'
echo 'LEGACY_DELEGATE_ROUTES_ARE_NOT_ASSUMED_CANONICAL=YES'
echo 'QUESTION=WHAT_EXACT_REQUEST_CONTRACT_AND_AUTHORITY_PRECONDITIONS_DOES_REGISTERED_GOVERNANCE_DELEGATION_ROUTE_REQUIRE'
echo 'IMPLEMENTATION_PERFORMED=NO'
echo 'LIVE_TASK_SUBMISSION_PERFORMED=NO'
echo 'NEW_AUTHORITY_ALLOWED=NO'
echo 'NEXT_STEP=DERIVE_SAFE_LIVE_REQUEST_FROM_REGISTERED_GOVERNANCE_DELEGATION_ROUTE'

printf '\n=== SCOPED SAFETY ===\n'
test -z "$(git diff --cached --name-only)"
AFTER_UNSTAGED="$(git diff --name-only)"
test "$BEFORE_UNSTAGED" = "$AFTER_UNSTAGED"
echo 'PREEXISTING_UNSTAGED_STATE=PRESERVED'
