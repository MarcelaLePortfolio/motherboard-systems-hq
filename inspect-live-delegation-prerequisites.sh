#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="c9381875c"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

BEFORE_UNSTAGED="$(git diff --name-only)"

printf '\n=== CANONICAL PACKAGE CANDIDATES ===\n'
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
SELECT
  project_id,
  package_id,
  package_version,
  conversation_id,
  created_at
FROM matilda_canonical_packages
ORDER BY created_at DESC;
SQL

printf '\n=== EXISTING DELEGATIONS ===\n'
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
SELECT
  delegation_id,
  project_id,
  package_id,
  package_version,
  authorization_state,
  authorization_timestamp,
  delegated_by,
  created_at
FROM governance_delegations
ORDER BY created_at DESC;
SQL

printf '\n=== AUTHORIZATION STATE SEMANTICS ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B20 -A60 \
  'authorization_state|AUTHORIZED|authorization_timestamp|delegated_by' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== CANONICAL PACKAGE / DELEGATION INVARIANTS ===\n'
sed -n '704,820p' db/governance-runtime.ts

printf '\n=== DOWNSTREAM DELEGATION CONSUMERS ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B25 -A80 \
  'governance_delegations|delegation_id|authorization_state' \
  server db routes \
  2>/dev/null \
  | grep -vE \
    'production-delegation-entry-point|production-delegation-consumer|governance-delegation-route|\.test\.|\.spec\.' \
  || true

printf '\n=== CLASSIFICATION ===\n'
echo 'CURRENT_OBJECTIVE=LIVE_END_TO_END_DELEGATED_TASK_VALIDATION'
echo 'REGISTERED_LIVE_DELEGATION_ROUTE=/api/governance/delegation'
echo 'EXISTING_CANONICAL_PACKAGE_REQUIRED=YES'
echo 'SYNTHETIC_CANONICAL_PACKAGE_ALLOWED=NO'
echo 'EXISTING_AUTHORITY_REQUIRED=YES'
echo 'NEW_AUTHORITY_ALLOWED=NO'
echo 'LIVE_TASK_SUBMISSION_PERFORMED=NO'
echo 'IMPLEMENTATION_PERFORMED=NO'
echo 'QUESTION=WHICH_EXISTING_CANONICAL_PACKAGE_AND_AUTHORIZATION_STATE_CAN_SAFELY_BACK_THE_FIRST_LIVE_DELEGATION'
echo 'NEXT_STEP=CLASSIFY_EXISTING_PACKAGE_AND_AUTHORITY_THEN_PREPARE_BOUNDED_LIVE_REQUEST'

printf '\n=== SCOPED SAFETY ===\n'
test -z "$(git diff --cached --name-only)"

AFTER_UNSTAGED="$(git diff --name-only)"
test "$BEFORE_UNSTAGED" = "$AFTER_UNSTAGED"
echo 'PREEXISTING_UNSTAGED_STATE=PRESERVED'
