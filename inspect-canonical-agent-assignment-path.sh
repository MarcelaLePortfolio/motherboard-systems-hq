#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== MATILDA ROUTING RUNTIME ===\n'
sed -n '1,420p' db/matilda-routing-runtime.ts 2>/dev/null || true

printf '\n=== MATILDA ASSIGNMENT RUNTIME ===\n'
sed -n '1,520p' db/matilda-assignment-runtime.ts 2>/dev/null || true

printf '\n=== MATILDA DELEGATION RUNTIME ===\n'
sed -n '1,520p' db/matilda-delegation-runtime.ts 2>/dev/null || true

printf '\n=== PRODUCTION DELEGATION CONSUMER ===\n'
sed -n '1,520p' server/delegation/production-delegation-consumer.ts 2>/dev/null || true

printf '\n=== PRODUCTION DELEGATION ENTRY POINT ===\n'
sed -n '1,520p' server/delegation/production-delegation-entry-point.ts 2>/dev/null || true

printf '\n=== MATILDA ROUTING / ASSIGNMENT ROUTES ===\n'
sed -n '1,420p' server/routes/matilda-routing-route.ts 2>/dev/null || true
sed -n '1,420p' server/routes/matilda-assignment-route.ts 2>/dev/null || true
sed -n '1,420p' server/routes/matilda-delegation-route.ts 2>/dev/null || true

printf '\n=== EXACT ASSIGNED-AGENT WRITERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B40 -A100 \
  '(assigned_agent[[:space:]]*[:=]|assignedAgent[[:space:]]*[:=]|INSERT INTO .*assignment|INSERT INTO .*execution_plan)' \
  db server \
  2>/dev/null | head -n 5000 || true

printf '\n=== NAMED IDENTITY REFERENCES IN ASSIGNMENT LINEAGE ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B20 -A60 \
  '(cade|effie|atlas|matilda|ellis|bastion|stryxx)' \
  db/matilda-routing-runtime.ts \
  db/matilda-assignment-runtime.ts \
  db/matilda-delegation-runtime.ts \
  server/delegation \
  server/routes/matilda-routing-route.ts \
  server/routes/matilda-assignment-route.ts \
  server/routes/matilda-delegation-route.ts \
  2>/dev/null | head -n 5000 || true

printf '\n=== DURABLE ASSIGNMENT / ROUTING SCHEMA ===\n'
sqlite3 db/main.db <<'SQL'
.headers on
.mode column

SELECT name, sql
FROM sqlite_master
WHERE type='table'
  AND (
    name LIKE '%routing%'
    OR name LIKE '%assignment%'
    OR name LIKE '%delegation%'
    OR name LIKE '%execution_plan%'
  )
ORDER BY name;
SQL

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=WHAT_EXACT_CODE_SELECTS_CADE_AS_ASSIGNED_AGENT'
echo 'QUESTION_2=IS_CADE_SELECTION_HARDCODED_DERIVED_OR_RECONCILED'
echo 'QUESTION_3=DO_ANY_OTHER_IDENTITIES_ENTER_THE_DURABLE_ASSIGNMENT_LINEAGE'
echo 'QUESTION_4=IS_ROUTER_AGENT_ID_UNION_SEPARATE_FROM_CANONICAL_DURABLE_AGENT_IDENTITY'
echo 'QUESTION_5=DOES_RECONCILIATION_DEFINE_ADDITIONAL_AGENT_ENTITIES_OUTSIDE_THIS_PATH'
echo 'IDENTITY_MUTATION_PERFORMED=NO'
echo 'DELEGATION_MUTATION_PERFORMED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== REPOSITORY STATE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"
git status --short
