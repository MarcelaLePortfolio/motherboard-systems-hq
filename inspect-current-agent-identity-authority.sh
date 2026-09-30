#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== VERIFIED FINDINGS ===\n'
echo 'PHASE17_ROUTER_PRODUCTION_CALLERS=NONE_FOUND'
echo 'PHASE17_ROUTER_CURRENT_PRODUCTION_IDENTITY_AUTHORITY=NO_EVIDENCE'
echo 'DURABLE_EXECUTION_PLAN_ASSIGNED_AGENT=cade'
echo 'DURABLE_INTERPRETATION_ACTOR=matilda'
echo 'DURABLE_ATLAS_AGENT_IDENTITY=NOT_FOUND'
echo 'DELEGATION_DELEGATED_BY=marcela'
echo 'NEXT_TARGET=CURRENT_ASSIGNMENT_AND_EXECUTION_PLAN_AUTHORITY'

printf '\n=== ASSIGNMENT RUNTIME ===\n'
sed -n '1,220p' db/matilda-assignment-runtime.ts 2>/dev/null || true

printf '\n=== ASSIGNMENT ROUTE ===\n'
sed -n '1,180p' server/routes/matilda-assignment-route.ts 2>/dev/null || true

printf '\n=== EXECUTION PLANNING RUNTIME ===\n'
sed -n '1,220p' db/matilda-execution-planning-runtime.ts 2>/dev/null || true

printf '\n=== EXECUTION PLANNING ROUTE ===\n'
sed -n '1,180p' server/routes/matilda-execution-planning-route.ts 2>/dev/null || true

printf '\n=== CURRENT ASSIGNMENT TABLES ===\n'
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
SELECT name
FROM sqlite_master
WHERE type='table'
  AND (
    lower(name) LIKE '%assignment%'
    OR lower(name) LIKE '%execution_plan%'
  )
ORDER BY name;
SQL

printf '\n=== ASSIGNMENT / EXECUTION PLAN SCHEMAS ===\n'
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
PRAGMA table_info(matilda_assignments);
PRAGMA table_info(matilda_execution_plans);
SQL

printf '\n=== DURABLE ASSIGNMENTS ===\n'
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
SELECT *
FROM matilda_assignments
ORDER BY rowid DESC
LIMIT 50;
SQL

printf '\n=== DURABLE EXECUTION PLANS ===\n'
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
SELECT *
FROM matilda_execution_plans
ORDER BY rowid DESC
LIMIT 50;
SQL

printf '\n=== ASSIGNED_AGENT WRITERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='*.test.ts' --exclude='*.spec.ts' \
  '(assigned_agent|persistMatildaAssignment|persistMatildaExecutionPlan|create.*Assignment|create.*ExecutionPlan)' \
  server db \
  2>/dev/null | head -n 1200 || true

printf '\n=== NAMED AGENT WRITES IN CURRENT RUNTIME ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='*.test.ts' --exclude='*.spec.ts' \
  '("cade"|"effie"|"atlas"|"matilda").*(assigned_agent|agent)|((assigned_agent|agent).*)("cade"|"effie"|"atlas"|"matilda")' \
  server db \
  2>/dev/null | head -n 1000 || true

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=WHAT_CURRENT_AUTHORITY_CREATES_ASSIGNED_AGENT_CADE'
echo 'QUESTION_2=IS_ASSIGNED_AGENT_FREEFORM_OR_CONSTRAINED_TO_A_CURRENT_AGENT_SET'
echo 'QUESTION_3=DO_ASSIGNMENTS_ESTABLISH_CADE_AS_THE_ONLY_DURABLY_ASSIGNED_EXECUTION_AGENT'
echo 'QUESTION_4=ARE_MATILDA_AND_ATLAS_PARTICIPANTS_WITH_DIFFERENT_ROLES_RATHER_THAN_INTERCHANGEABLE_EXECUTION_AGENTS'
echo 'QUESTION_5=WHAT_IDENTITY_SHOULD_FIRST_LIVE_DELEGATION_USE_WITHOUT_SYNTHESIZING_AUTHORITY'
echo 'LIVE_DELEGATION_PERFORMED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== REPOSITORY STATE ===\n'
git status --short
