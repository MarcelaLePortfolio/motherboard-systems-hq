#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n=== GOVERNANCE RUNTIME ACTIVATION · DELEGATION ROUTE MOUNT READINESS ===\n'
printf '%s\n' \
'CURRENT_CHECKPOINT=3c58c0f2' \
'CANONICAL_DELEGATION_PERSISTENCE=VALIDATED' \
'FRESH_SCHEMA_CANONICAL_ROOT=ALIGNED' \
'DOWNSTREAM_GOVERNANCE_ACTIVATION=NO' \
'QUESTION=IS_THE_EXPLICIT_DELEGATION_ROUTE_ALREADY_MOUNTED_AND_IF_NOT_WHAT_EXACT_MOUNT_PATTERN_SHOULD_BE_USED'

printf '\n=== SERVER INDEX ===\n'
sed -n '1,320p' server/index.ts

printf '\n=== ROUTER IMPORTS / MOUNTS ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git \
-E 'createGovernanceDelegationRouter|governance-delegation-route|app\.use|router\.use|matildaCanonical|canonical-package' \
server 2>/dev/null | head -500

printf '\n=== NEIGHBORING ROUTE MOUNT PATTERNS ===\n'
grep -n -A12 -B12 \
-E 'create.*Router|app\.use|canonical' \
server/index.ts | head -500

printf '\n=== DELEGATION ROUTE CONTRACT ===\n'
sed -n '1,260p' server/routes/governance-delegation-route.ts

printf '\n=== DELEGATION ROUTE TEST ===\n'
sed -n '1,240p' server/routes/governance-delegation-route.test.ts

printf '\n=== BOUNDARY ===\n'
printf '%s\n' \
'ROUTE_CHANGE_PERFORMED=NO' \
'DELEGATION_CREATED=NO' \
'VALIDATION_CHANGE=NONE' \
'ENVELOPE_CHANGE=NONE' \
'ROUTING_CHANGE=NONE' \
'ASSIGNMENT_CHANGE=NONE' \
'EXECUTION_CHANGE=NONE'

printf '\n=== WORKTREE ===\n'
git status --short
