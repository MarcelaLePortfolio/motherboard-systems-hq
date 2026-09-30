#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== EXECUTION PLAN ROW COUNT ===\n'
sqlite3 -header -column db/main.db "
SELECT COUNT(*) AS execution_plan_count
FROM matilda_execution_plans;
" 2>/dev/null || true

printf '\n=== ACTUAL PERSISTED ASSIGNED AGENT VALUES ===\n'
sqlite3 -header -column db/main.db "
SELECT
  COALESCE(NULLIF(TRIM(assigned_agent), ''), '<EMPTY>') AS assigned_agent,
  COUNT(*) AS row_count,
  MIN(created_at) AS first_seen,
  MAX(created_at) AS last_seen
FROM matilda_execution_plans
GROUP BY COALESCE(NULLIF(TRIM(assigned_agent), ''), '<EMPTY>')
ORDER BY assigned_agent;
" 2>/dev/null || true

printf '\n=== EXECUTION PLAN IDENTITY ROWS ===\n'
sqlite3 -header -column db/main.db "
SELECT
  execution_plan_id,
  assignment_id,
  package_id,
  lineage_id,
  assigned_agent,
  status,
  created_at
FROM matilda_execution_plans
ORDER BY created_at;
" 2>/dev/null || true

printf '\n=== EXACT EXECUTION PLAN INSERT PRODUCERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' \
  -B35 -A100 \
  'INSERT[[:space:]]+INTO[[:space:]]+matilda_execution_plans' \
  server db routes scripts \
  2>/dev/null || true

printf '\n=== EXACT ASSIGNED_AGENT FIELD PRODUCERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' \
  -B25 -A80 \
  '(assigned_agent[[:space:]]*[:=]|assignedAgent[[:space:]]*[:=])' \
  server db routes \
  2>/dev/null || true

printf '\n=== EXECUTION PLANNING RUNTIME ===\n'
sed -n '1,420p' db/matilda-execution-planning-runtime.ts 2>/dev/null || true

printf '\n=== ASSIGNMENT / DELEGATION SOURCES REFERENCED BY EXECUTION PLANNING ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' \
  -B25 -A80 \
  '(assignment_id|assigned_agent|routing_destination|delegation)' \
  db/matilda-execution-planning-runtime.ts \
  db/*delegat* \
  server/*delegat* \
  server/**/*delegat* \
  2>/dev/null || true

printf '\n=== ATLAS CURRENT DURABLE SURFACE SUMMARY ===\n'
sqlite3 -header -column db/main.db "
SELECT
  COUNT(*) AS observation_count,
  COUNT(DISTINCT project_id) AS project_count,
  COUNT(DISTINCT conversation_id) AS conversation_count,
  MIN(observed_at) AS first_observed,
  MAX(observed_at) AS last_observed
FROM atlas_historical_observations;
" 2>/dev/null || true

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=WHICH_IDENTITIES_HAVE_ACTUALLY_BEEN_PERSISTED_IN_ASSIGNED_AGENT'
echo 'QUESTION_2=WHAT_EXACT_RUNTIME_INPUT_SUPPLIES_ASSIGNED_AGENT'
echo 'QUESTION_3=IS_ASSIGNED_AGENT_DERIVED_FROM_DELEGATION_ROUTING_OR_ANOTHER_CONTRACT'
echo 'QUESTION_4=DO_NOT_INFER_GLOBAL_CANONICAL_AGENT_REGISTRY_FROM_FIELD_NAMES'
echo 'QUESTION_5=DO_NOT_EQUATE_MATILDA_WITH_CHIEF_OF_STAFF'
echo 'KNOWN_ATLAS_DURABLE_PERSISTENCE_SURFACE=atlas_historical_observations'
echo 'IDENTITY_MUTATION_PERFORMED=NO'
echo 'AUTHORITY_MUTATION_PERFORMED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== REPOSITORY STATE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"
git status --short
