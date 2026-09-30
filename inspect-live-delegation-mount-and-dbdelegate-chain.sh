#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== BASELINE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"

printf '\n=== DELEGATION ENDPOINT MOUNT ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='*.test.ts' --exclude='*.test.mjs' \
  --include='*.ts' --include='*.mjs' \
  -B40 -A120 \
  '(delegate-taskspec|handleDelegateTaskSpec|/delegate)' \
  server/index.ts server \
  2>/dev/null | head -n 6000 || true

printf '\n=== DBDELEGATETASK DEFINITION ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' \
  -B50 -A180 \
  '(function dbDelegateTask|dbDelegateTask[[:space:]]*=|export .*dbDelegateTask)' \
  server db \
  2>/dev/null | head -n 6000 || true

printf '\n=== DBDELEGATETASK CALLERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' \
  -B40 -A140 \
  'dbDelegateTask[[:space:]]*\(' \
  server db scripts \
  2>/dev/null | head -n 7000 || true

printf '\n=== DELEGATED IDENTITY PERSISTENCE ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' \
  -B40 -A140 \
  '(assigned_agent|assignedAgent|agent_id|agentId|target_agent|targetAgent|task\.created)' \
  server db \
  2>/dev/null | head -n 9000 || true

printf '\n=== MATILDA ASSIGNMENT ROUTE MOUNT ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='matilda-assignment-route.ts' \
  --include='*.ts' --include='*.mjs' \
  -B30 -A100 \
  '(matilda-assignment-route|/api/matilda/assignment)' \
  server/index.ts server \
  2>/dev/null | head -n 4000 || true

printf '\n=== DATABASE OWNERSHIP SPLIT ===\n'
grep -nE \
  '(new Database|motherboard\.sqlite|db/main\.db|assigned_agent)' \
  db/matilda-assignment-runtime.ts \
  db/matilda-execution-planning-runtime.ts \
  2>/dev/null || true

printf '\n=== CLASSIFICATION ===\n'
echo 'QUESTION_1=IS_DELEGATE_TASKSPEC_PRODUCTION_MOUNTED'
echo 'QUESTION_2=WHERE_DOES_DBDELEGATETASK_PERSIST_CADE_EFFIE_ATLAS'
echo 'QUESTION_3=WHAT_CURRENT_RUNTIME_CONSUMES_THAT_IDENTITY'
echo 'QUESTION_4=DOES_DOWNSTREAM_EXECUTION_REVALIDATE_AGENT_IDENTITY'
echo 'QUESTION_5=IS_MATILDA_ASSIGNMENT_ROUTE_MOUNTED'
echo 'QUESTION_6=IS_MOTHERBOARD_SQLITE_ASSIGNMENT_PATH_STALE_OR_SEPARATE'
echo 'QUESTION_7=CAN_CADE_EFFIE_ATLAS_BE_CLASSIFIED_AS_CURRENT_LIVE_DELEGATABLE_IDENTITIES'
echo 'QUESTION_8=IS_ANY_SINGLE_CANONICAL_AGENT_REGISTRY_PROVEN'
echo 'IDENTITY_MUTATION_PERFORMED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'AUTHORITY_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== FINAL REPOSITORY STATE ===\n'
git status --short
