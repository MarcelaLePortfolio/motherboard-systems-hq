#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== CURRENT EXECUTION PLAN ASSIGNMENTS ===\n'
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
ORDER BY created_at ASC;
" 2>/dev/null || true

printf '\n=== DISTINCT CURRENT ASSIGNED AGENTS ===\n'
sqlite3 -header -column db/main.db "
SELECT
  assigned_agent,
  COUNT(*) AS assignment_count,
  MIN(created_at) AS first_seen,
  MAX(created_at) AS last_seen
FROM matilda_execution_plans
GROUP BY assigned_agent
ORDER BY assigned_agent;
" 2>/dev/null || true

printf '\n=== CURRENT ASSIGNMENT PRODUCERS ONLY ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' \
  -B20 -A60 \
  '(INSERT INTO matilda_execution_plans|assigned_agent[[:space:]]*[:=]|assignedAgent[[:space:]]*[:=])' \
  server db routes scripts \
  2>/dev/null | head -n 3000 || true

printf '\n=== CURRENT ROUTING DESTINATION PRODUCERS ONLY ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' \
  -B20 -A60 \
  '(routing_destination[[:space:]]*[:=]|routingDestination[[:space:]]*[:=])' \
  server db routes scripts \
  2>/dev/null | head -n 3000 || true

printf '\n=== CURRENT NAMED AGENT CONTRACTS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' \
  -B12 -A30 \
  '(AgentId|AgentSnapshot|matilda|cade|effie|atlas|ellis|bastion|stryxx)' \
  server/orchestration server/orchestrator server/execution db \
  2>/dev/null | head -n 5000 || true

printf '\n=== CURRENT DATABASE OBJECTS CONTAINING AGENT FIELDS ===\n'
sqlite3 db/main.db "
SELECT type, name, sql
FROM sqlite_master
WHERE lower(COALESCE(sql,'')) LIKE '%assigned_agent%'
   OR lower(COALESCE(sql,'')) LIKE '%agent_id%'
   OR lower(COALESCE(sql,'')) LIKE '%routing_destination%'
ORDER BY type, name;
" 2>/dev/null || true

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=WHICH_IDENTITIES_ARE_ACTUALLY_PERSISTED_AS_ASSIGNED_AGENTS'
echo 'QUESTION_2=WHICH_CURRENT_PRODUCTION_CODE_PATH_CREATES_THOSE_ASSIGNMENTS'
echo 'QUESTION_3=DOES_ROUTING_DESTINATION_HAVE_A_SEPARATE_IDENTITY_MODEL'
echo 'QUESTION_4=IS_AGENT_IDENTITY_CANONICAL_OR_CONTEXT_SPECIFIC'
echo 'QUESTION_5=DO_NOT_EQUATE_MATILDA_WITH_CHIEF_OF_STAFF'
echo 'IDENTITY_MUTATION_PERFORMED=NO'
echo 'AUTHORITY_MUTATION_PERFORMED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== REPOSITORY STATE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"
git status --short
