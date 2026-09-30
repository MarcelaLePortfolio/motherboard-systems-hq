#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="d0db33fd0"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

BEFORE_UNSTAGED="$(git diff --name-only)"

printf '\n=== LIVE CANONICAL PACKAGE INVENTORY ===\n'
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
SELECT
  project_id,
  package_id,
  package_version,
  conversation_id,
  requested_outcome,
  scope,
  containment,
  constraints,
  success_criteria,
  created_at
FROM matilda_canonical_packages
ORDER BY created_at DESC;
SQL

printf '\n=== LIVE DELEGATION INVENTORY ===\n'
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

printf '\n=== AUTHORIZATION STATES ACTUALLY PERSISTED ===\n'
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
SELECT
  authorization_state,
  COUNT(*) AS row_count,
  MIN(created_at) AS first_seen,
  MAX(created_at) AS last_seen
FROM governance_delegations
GROUP BY authorization_state
ORDER BY authorization_state;
SQL

printf '\n=== CANONICAL PACKAGES WITH EXISTING DELEGATION AUTHORITY ===\n'
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
SELECT
  c.project_id,
  c.package_id,
  c.package_version,
  c.conversation_id,
  d.delegation_id,
  d.authorization_state,
  d.authorization_timestamp,
  d.delegated_by,
  d.created_at AS delegation_created_at
FROM matilda_canonical_packages c
JOIN governance_delegations d
  ON d.project_id = c.project_id
 AND d.package_id = c.package_id
 AND d.package_version = c.package_version
ORDER BY d.created_at DESC;
SQL

printf '\n=== AUTHORIZATION STATE EXACT-MATCH CONSUMERS ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B20 -A50 \
  'authorization_state[[:space:]]*(===|!==|==|!=)|authorization_state.*AUTHORIZED|AUTHORIZED.*authorization_state|authorizationState.*AUTHORIZED|authorized.*delegation' \
  server db routes \
  2>/dev/null || true

printf '\n=== DELEGATION AUTHORITY READERS ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B20 -A60 \
  'FROM governance_delegations|JOIN governance_delegations|load.*Delegation|delegation.*authorization' \
  server db routes \
  2>/dev/null || true

printf '\n=== LIVE DELEGATION ROUTE CONTRACT ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B30 -A100 \
  '/api/governance/delegation|governance/delegation' \
  server routes \
  2>/dev/null || true

printf '\n=== CLASSIFICATION ===\n'
echo 'CURRENT_OBJECTIVE=LIVE_END_TO_END_DELEGATED_TASK_VALIDATION'
echo 'BASELINE=d0db33fd0'
echo 'PRIOR_INSPECTION_CONFIRMED_CANONICAL_PACKAGE_REQUIRED=YES'
echo 'PRIOR_INSPECTION_CONFIRMED_NEW_AUTHORITY_ALLOWED=NO'
echo 'AUTHORIZATION_STATE_IS_CURRENTLY_FREEFORM_AT_PERSISTENCE_BOUNDARY=YES'
echo 'SAFE_AUTHORIZATION_VALUE_MUST_BE_DERIVED_FROM_EXISTING_DURABLE_AUTHORITY_OR_EXACT_DOWNSTREAM_CONSUMER=YES'
echo 'LIVE_TASK_SUBMISSION_PERFORMED=NO'
echo 'NEW_DELEGATION_CREATED=NO'
echo 'IMPLEMENTATION_PERFORMED=NO'
echo 'NEXT_STEP=SELECT_ONLY_AN_EXISTING_CANONICAL_PACKAGE_WITH_PROVABLE_EXISTING_AUTHORITY_AND_PREPARE_EXACT_LIVE_REQUEST'

printf '\n=== SCOPED SAFETY ===\n'
test -z "$(git diff --cached --name-only)"

AFTER_UNSTAGED="$(git diff --name-only)"
test "$BEFORE_UNSTAGED" = "$AFTER_UNSTAGED"
echo 'PREEXISTING_UNSTAGED_STATE=PRESERVED'
