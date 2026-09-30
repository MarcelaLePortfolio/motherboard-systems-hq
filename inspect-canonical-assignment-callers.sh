#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== ALL createAssignment CALLERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B35 -A100 \
  'createAssignment\(' \
  server db scripts \
  2>/dev/null | head -n 6000 || true

printf '\n=== ALL createExecutionPlan CALLERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B35 -A100 \
  'createExecutionPlan\(' \
  server db scripts \
  2>/dev/null | head -n 6000 || true

printf '\n=== ROUTING DESTINATION TO ASSIGNED AGENT ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B40 -A120 \
  '(routing_destination|assigned_agent)' \
  server db \
  2>/dev/null | head -n 8000 || true

printf '\n=== PRODUCTION DELEGATION CONSUMER ===\n'
grep -nE \
  -B50 -A160 \
  '(assignment|assigned_agent|routing|routing_destination|delegation_target|execution_plan|cade|agent)' \
  server/delegation/production-delegation-consumer.ts \
  2>/dev/null | head -n 7000 || true

printf '\n=== EXECUTION PLANNING RUNTIME ===\n'
sed -n '1,620p' db/matilda-execution-planning-runtime.ts 2>/dev/null || true

printf '\n=== DURABLE ASSIGNED AGENT VALUES ===\n'
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
SELECT assigned_agent AS identity, COUNT(*) AS records
FROM matilda_execution_plans
GROUP BY assigned_agent
ORDER BY records DESC, identity;
SQL

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=WHAT_PRODUCTION_CODE_ACTUALLY_SELECTS_ASSIGNED_AGENT'
echo 'QUESTION_2=IS_CADE_SELECTED_BY_POLICY_ROUTING_RECONCILIATION_OR_CALLER_INPUT'
echo 'QUESTION_3=DO_MATILDA_EFFIE_ATLAS_OR_OTHER_IDENTITIES_ENTER_DURABLE_EXECUTION_LINEAGE'
echo 'QUESTION_4=IS_THERE_A_CANONICAL_AGENT_IDENTITY_BOUNDARY_DISTINCT_FROM_ROUTER_AGENT_ID'
echo 'QUESTION_5=DOES_RECONCILIATION_ESTABLISH_ADDITIONAL_AGENT_ENTITIES'
echo 'IDENTITY_MUTATION_PERFORMED=NO'
echo 'DELEGATION_MUTATION_PERFORMED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== REPOSITORY STATE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"
git status --short
