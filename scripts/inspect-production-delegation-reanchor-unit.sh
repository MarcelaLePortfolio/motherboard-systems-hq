#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n=== CORRIDOR 1 · PRODUCTION DELEGATION REANCHOR UNIT ===\n'
printf '%s\n' \
'CURRENT_CHECKPOINT=7ffb4f46' \
'IMPLEMENTATION_AUTHORIZED=YES' \
'CANONICAL_VERSION_IDENTITY_PREREQUISITE=CLOSED' \
'LEGACY_SMOKE_LINEAGE_PRESERVE=YES' \
'QUESTION=WHAT_IS_THE_MINIMUM_LIVE_CODE_AND_SCHEMA_CHANGE_FOR_NEW_DELEGATIONS'

printf '\n=== GOVERNANCE DELEGATION PERSISTENCE ===\n'
sed -n '680,790p' db/governance-runtime.ts

printf '\n=== PRODUCTION DELEGATION ENTRY POINT ===\n'
sed -n '1,240p' server/delegation/production-delegation-entry-point.ts

printf '\n=== PRODUCTION DELEGATION CONSUMER ===\n'
sed -n '1,220p' server/delegation/production-delegation-consumer.ts

printf '\n=== EXPLICIT DELEGATION ROUTE ===\n'
sed -n '1,240p' server/routes/governance-delegation-route.ts

printf '\n=== GOVERNANCE SCHEMA INITIALIZATION / DATABASE BOUNDARY ===\n'
sed -n '190,330p' db/governance-runtime.ts
grep -Rni --exclude-dir=node_modules --exclude-dir=.git \
-E 'initializeGovernance|governanceSchema|governance-runtime' \
server db | head -250

printf '\n=== DELEGATION TEST SURFACE ===\n'
sed -n '1,220p' server/delegation/production-delegation-entry-point.test.ts
sed -n '1,180p' server/delegation/production-delegation-consumer.test.ts
sed -n '1,220p' server/routes/governance-delegation-route.test.ts

printf '\n=== WORKTREE ===\n'
git status --short
