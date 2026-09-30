#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== BASELINE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"

printf '\n=== EXECUTION PLAN SCHEMA ===\n'
sqlite3 -header -column db/main.db "
PRAGMA table_info(matilda_execution_plans);
" 2>/dev/null || true

printf '\n=== EXECUTION PLAN ROWS ===\n'
sqlite3 -header -column db/main.db "
SELECT *
FROM matilda_execution_plans
ORDER BY rowid;
" 2>/dev/null || true

printf '\n=== DISTINCT ASSIGNED_AGENT VALUES ===\n'
if sqlite3 db/main.db "PRAGMA table_info(matilda_execution_plans);" |
  awk -F'|' '{print $2}' |
  grep -qx 'assigned_agent'; then
  sqlite3 -header -column db/main.db "
  SELECT
    COALESCE(NULLIF(TRIM(assigned_agent), ''), '<EMPTY>') AS assigned_agent,
    COUNT(*) AS row_count
  FROM matilda_execution_plans
  GROUP BY COALESCE(NULLIF(TRIM(assigned_agent), ''), '<EMPTY>')
  ORDER BY assigned_agent;
  "
else
  echo 'assigned_agent column absent'
fi

printf '\n=== ASSIGNED_AGENT PRODUCER SEARCH ===\n'
grep -RniE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  --include='*.ts' \
  --include='*.mjs' \
  -B35 -A100 \
  'assigned_agent|assignedAgent|matilda_execution_plans' \
  db server routes scripts \
  2>/dev/null || true

printf '\n=== EXECUTION PLANNING CALL SITES ===\n'
grep -RniE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  --include='*.ts' \
  --include='*.mjs' \
  -B40 -A100 \
  'createExecutionPlan|executionPlanning|execution_planning|execution_plan' \
  db server routes scripts \
  2>/dev/null || true

printf '\n=== DELEGATION / ASSIGNMENT BOUNDARY ===\n'
grep -RniE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  --include='*.ts' \
  -B20 -A50 \
  'routing_authorized|assignment_authorized|execution_authorized|new_authority_introduced' \
  server/delegation server/routes/governance-delegation-route.ts \
  2>/dev/null || true

printf '\n=== AGENT-LIKE IDENTIFIERS IN PRODUCTION SOURCE ===\n'
grep -RniE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  --exclude='*.test.ts' \
  --include='*.ts' \
  --include='*.mjs' \
  '\b(matilda|atlas|cade|effie|chief[ _-]?of[ _-]?staff)\b' \
  server db routes \
  2>/dev/null || true

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=WHICH_IDENTITIES_ARE_ACTUALLY_PERSISTED_IN_ASSIGNED_AGENT'
echo 'QUESTION_2=WHAT_EXACT_RUNTIME_INPUT_SUPPLIES_ASSIGNED_AGENT'
echo 'QUESTION_3=WHAT_FUNCTION_WRITES_ASSIGNED_AGENT'
echo 'QUESTION_4=DOES_DELEGATION_SUPPLY_OR_AUTHORIZE_ASSIGNED_AGENT'
echo 'QUESTION_5=DO_NOT_INFER_GLOBAL_AGENT_REGISTRY_FROM_FIELD_NAMES'
echo 'QUESTION_6=DO_NOT_EQUATE_MATILDA_WITH_CHIEF_OF_STAFF'
echo 'IDENTITY_MUTATION_PERFORMED=NO'
echo 'AUTHORITY_MUTATION_PERFORMED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== REPOSITORY STATE ===\n'
git status --short
