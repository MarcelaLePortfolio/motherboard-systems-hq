#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== CURRENT DETERMINATION ===\n'
echo 'MATILDA_ASSIGNMENTS_TABLE_IN_LIVE_DB=ABSENT'
echo 'MATILDA_EXECUTION_PLANS_TABLE_IN_LIVE_DB=PRESENT'
echo 'EXECUTION_PLAN_ASSIGNED_AGENT_COLUMN=FREEFORM_TEXT_AT_SCHEMA_BOUNDARY'
echo 'DURABLE_EXECUTION_PLAN_AGENT_OBSERVED=cade'
echo 'EXECUTION_PLAN_ITSELF_GRANTS_EXECUTION_AUTHORITY=NO'
echo 'ADDITIONAL_CURRENT_NAMED_AGENT_PATHS=FOUND'
echo 'NEXT_TARGET=TRACE_CURRENT_AGENT_SELECTION_AND_TASK_DELEGATION_CONTRACTS'

printf '\n=== PACKAGE TO EXECUTION COMPILER ===\n'
sed -n '1,180p' server/execution/package-to-execution-compiler.ts 2>/dev/null || true

printf '\n=== GOVERNED PLANNING ROUTE AGENT SELECTION ===\n'
sed -n '180,260p' server/routes/governed-planning-route.mjs 2>/dev/null || true

printf '\n=== TASK MUTATION DEFAULT AGENT ===\n'
sed -n '1,120p' server/tasks-mutations.mjs 2>/dev/null || true

printf '\n=== DELEGATE TASKSPEC CONTRACT ===\n'
sed -n '1,180p' server/api/tasks-mutations/delegate-taskspec.mjs 2>/dev/null || true

printf '\n=== CURRENT PRODUCTION CALLERS OF PACKAGE COMPILER ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='*.test.ts' --exclude='*.spec.ts' \
  '(compile.*Package|package-to-execution-compiler|compilePackage)' \
  server db scripts \
  2>/dev/null | head -n 800 || true

printf '\n=== CURRENT PRODUCTION CALLERS OF TASK DELEGATION ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='*.test.ts' --exclude='*.spec.ts' \
  '(delegate-taskspec|delegateTask|tasks-mutations|assigned_agent|agent:[[:space:]]*"cade"|agent:[[:space:]]*"effie"|agent:[[:space:]]*"atlas"|agent:[[:space:]]*"matilda")' \
  server db scripts \
  2>/dev/null | head -n 1400 || true

printf '\n=== TABLES WITH AGENT-LIKE COLUMNS ===\n'
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
SELECT
  m.name AS table_name,
  p.name AS column_name,
  p.type AS column_type
FROM sqlite_master m
JOIN pragma_table_info(m.name) p
WHERE m.type='table'
  AND (
    lower(p.name) LIKE '%agent%'
    OR lower(p.name) LIKE '%actor%'
    OR lower(p.name) LIKE '%assignee%'
    OR lower(p.name) LIKE '%delegat%'
  )
ORDER BY m.name, p.cid;
SQL

printf '\n=== DISTINCT DURABLE AGENT / ACTOR VALUES ===\n'
python3 - <<'PY'
import sqlite3

db = sqlite3.connect("db/main.db")
rows = db.execute("""
SELECT m.name, p.name
FROM sqlite_master m
JOIN pragma_table_info(m.name) p
WHERE m.type='table'
  AND (
    lower(p.name) LIKE '%agent%'
    OR lower(p.name) LIKE '%actor%'
    OR lower(p.name) LIKE '%assignee%'
    OR lower(p.name) LIKE '%delegated_by%'
  )
ORDER BY m.name, p.cid
""").fetchall()

for table, column in rows:
    qt = '"' + table.replace('"', '""') + '"'
    qc = '"' + column.replace('"', '""') + '"'
    values = db.execute(
        f"SELECT {qc}, COUNT(*) FROM {qt} "
        f"WHERE {qc} IS NOT NULL AND trim(CAST({qc} AS TEXT)) <> '' "
        f"GROUP BY {qc} ORDER BY COUNT(*) DESC LIMIT 50"
    ).fetchall()

    print(f"\n--- {table}.{column} ---")
    if not values:
        print("(no values)")
    for value, count in values:
        print(f"{value!r}\t{count}")
PY

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=IS_CADE_SELECTED_BY_CURRENT_GOVERNED_PLANNING_RATHER_THAN_BY_LEGACY_ROUTER'
echo 'QUESTION_2=DO_CURRENT_TASK_CONTRACTS_RECOGNIZE_EFFIE_OR_ATLAS_AS_REAL_ASSIGNABLE_IDENTITIES'
echo 'QUESTION_3=IS_MATILDA_AN_INTERPRETATION_PLANNING_IDENTITY_RATHER_THAN_DEFAULT_EXECUTION_AGENT'
echo 'QUESTION_4=WHICH_AGENT_IDENTITIES_HAVE_CURRENT_DURABLE_RUNTIME_EVIDENCE'
echo 'QUESTION_5=WHICH_EXISTING_IDENTITY_CAN_BACK_FIRST_LIVE_DELEGATED_TASK_WITHOUT_CREATING_NEW_AUTHORITY'
echo 'LIVE_DELEGATION_PERFORMED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== REPOSITORY STATE ===\n'
git status --short
