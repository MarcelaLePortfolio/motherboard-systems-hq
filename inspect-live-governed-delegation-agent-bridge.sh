#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== ESTABLISHED CURRENT IDENTITY SURFACES ===\n'
echo 'PEC_AGENT_SET=matilda,cade,effie'
echo 'PEC_INTERPRETATION_AGENT=matilda'
echo 'PEC_PLANNING_AGENT=cade'
echo 'PEC_EXECUTION_AGENT=effie'
echo 'TASKSPEC_DELEGATION_TARGET_SET=cade,effie,atlas'
echo 'GOVERNED_PLANNING_RECORDED_AGENT=cade'
echo 'DURABLE_EXECUTION_PLAN_AGENT=cade'
echo 'ATLAS_CURRENT_TASKSPEC_TARGET=YES'
echo 'ATLAS_PEC_LIFECYCLE_MEMBER=NO'
echo 'IDENTITY_RECONCILIATION_REQUIRED_BEFORE_LIVE_DELEGATION=YES'

printf '\n=== GOVERNANCE DELEGATION ROUTE ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B30 -A140 \
  '(/api/governance/delegation|governance/delegation)' \
  server routes db \
  2>/dev/null | head -n 1200 || true

printf '\n=== GOVERNANCE DELEGATION PERSISTENCE ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B30 -A120 \
  '(governance_delegations|persist.*delegation|create.*delegation|delegation_id)' \
  server db \
  2>/dev/null | head -n 1600 || true

printf '\n=== DELEGATION TO TASK BRIDGE ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='*.test.ts' --exclude='*.spec.ts' \
  -B30 -A120 \
  '(delegate-taskspec|dbDelegateTask|governance_delegations|delegation_id|assigned_agent|target)' \
  server/execution server/lifecycle server/operational server/routes server/api db \
  2>/dev/null | head -n 2000 || true

printf '\n=== PEC RUNTIME BINDER ===\n'
sed -n '1,300p' server/execution/pec-runtime-binder.ts 2>/dev/null || true

printf '\n=== PRODUCTION LIFECYCLE HANDOFF ===\n'
sed -n '1,360p' server/lifecycle/production-envelope-lifecycle-handoff.ts 2>/dev/null || true

printf '\n=== CURRENT GOVERNANCE DELEGATION ===\n'
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

printf '\n=== CORRESPONDING CANONICAL PACKAGE ===\n'
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
SELECT
  c.project_id,
  c.package_id,
  c.package_version,
  c.conversation_id,
  c.requested_outcome,
  c.approval_actor,
  c.created_at
FROM matilda_canonical_packages c
JOIN governance_delegations d
  ON d.project_id = c.project_id
 AND d.package_id = c.package_id
 AND d.package_version = c.package_version
ORDER BY d.created_at DESC;
SQL

printf '\n=== EXISTING EXECUTION PLAN FOR DELEGATED PACKAGE ===\n'
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
SELECT p.*
FROM matilda_execution_plans p
WHERE EXISTS (
  SELECT 1
  FROM governance_delegations d
  WHERE d.project_id = p.project_id
    AND d.package_id = p.package_id
)
ORDER BY p.rowid DESC;
SQL

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=DOES_GOVERNANCE_DELEGATION_ALREADY_BIND_TO_AN_AGENT_IDENTITY'
echo 'QUESTION_2=IF_NOT_WHICH_EXISTING_RUNTIME_BRIDGE_SELECTS_THE_AGENT'
echo 'QUESTION_3=DOES_THE_EXISTING_DELEGATED_PACKAGE_ALREADY_HAVE_A_DURABLE_EXECUTION_PLAN_AND_AGENT'
echo 'QUESTION_4=CAN_FIRST_LIVE_VALIDATION_CONSUME_EXISTING_CADE_OR_EFFIE_AUTHORITY_WITHOUT_CREATING_NEW_AUTHORITY'
echo 'QUESTION_5=IS_ATLAS_A_VALID_TASK_TARGET_BUT_OUTSIDE_THIS_SPECIFIC_GOVERNED_EXECUTION_LIFECYCLE'
echo 'NEW_DELEGATION_CREATED=NO'
echo 'LIVE_TASK_CREATED=NO'
echo 'NEW_AUTHORITY_CREATED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== REPOSITORY STATE ===\n'
git status --short
