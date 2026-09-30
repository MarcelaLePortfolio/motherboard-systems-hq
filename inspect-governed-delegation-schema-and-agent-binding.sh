#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== EXACT RELEVANT TABLE SCHEMAS ===\n'
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
SELECT name, sql
FROM sqlite_master
WHERE type = 'table'
  AND (
    name LIKE '%delegat%'
    OR name LIKE '%canonical%'
    OR name LIKE '%execution%plan%'
  )
ORDER BY name;
SQL

printf '\n=== GOVERNANCE DELEGATION SCHEMA ===\n'
sqlite3 db/main.db "PRAGMA table_info(governance_delegations);"

printf '\n=== CANONICAL PACKAGE SCHEMA ===\n'
sqlite3 db/main.db "PRAGMA table_info(matilda_canonical_packages);"

printf '\n=== EXACT AUTHORIZED DELEGATION ===\n'
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
SELECT *
FROM governance_delegations
WHERE delegation_id = '8782c8fa-7c82-4ca8-b7cb-3fce7d072b0c';
SQL

printf '\n=== EXACT CANONICAL PACKAGE ===\n'
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
SELECT *
FROM matilda_canonical_packages
WHERE package_id = 'pkg-68dfc4bc-791d-4156-b32a-e51e458b3160'
  AND package_version = 1;
SQL

printf '\n=== PACKAGE TO EXECUTION COMPILER ===\n'
sed -n '1,420p' server/execution/package-to-execution-compiler.ts 2>/dev/null || true

printf '\n=== PEC BINDER AND CALLERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B35 -A110 \
  '(executePackageThroughPEC|compilePackageToExecutionPlan)' \
  server db \
  2>/dev/null | head -n 2000 || true

printf '\n=== AGENT BINDING NEAR GOVERNANCE / EXECUTION ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B35 -A110 \
  '(delegation_id.*agent|agent.*delegation_id|delegated_to|assigned_agent|assignedAgent|target_agent|agent_id|task\.agent|agent:[[:space:]])' \
  server db \
  2>/dev/null | head -n 2400 || true

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=DOES_DURABLE_DELEGATION_STORE_AGENT_IDENTITY'
echo 'QUESTION_2=DOES_CANONICAL_PACKAGE_STORE_AGENT_IDENTITY'
echo 'QUESTION_3=DOES_PACKAGE_TO_EXECUTION_COMPILER_DERIVE_AGENT_ASSIGNMENT'
echo 'QUESTION_4=IS_AGENT_ASSIGNMENT_ROUTING_ONLY_OR_AUTHORITY_BEARING'
echo 'QUESTION_5=DOES_EXISTING_AUTHORIZED_DELEGATION_REACH_CADE_OR_EFFIE_WITHOUT_NEW_AUTHORITY'
echo 'QUESTION_6=IS_AN_AGENT_BINDING_BRIDGE_ACTUALLY_MISSING'
echo 'NEW_DELEGATION_CREATED=NO'
echo 'LIVE_TASK_CREATED=NO'
echo 'NEW_AUTHORITY_CREATED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== REPOSITORY STATE ===\n'
git status --short
