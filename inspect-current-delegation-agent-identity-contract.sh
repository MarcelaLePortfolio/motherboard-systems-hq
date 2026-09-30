#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== BASELINE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"

printf '\n=== DELEGATE TASKSPEC CONTRACT ===\n'
sed -n '1,360p' server/api/tasks-mutations/delegate-taskspec.mjs 2>/dev/null || true

printf '\n=== PRODUCTION MOUNT / IMPORT ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='*.test.ts' --exclude='*.test.mjs' \
  --include='*.ts' --include='*.mjs' \
  -B30 -A90 \
  '(handleDelegateTaskSpec|delegate-taskspec|tasks-mutations/delegate)' \
  server db scripts \
  2>/dev/null | head -n 4000 || true

printf '\n=== DB DELEGATE TASK DEFINITION AND CALLERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' \
  -B40 -A140 \
  '(dbDelegateTask|delegateTask)' \
  server db \
  2>/dev/null | head -n 6000 || true

printf '\n=== CURRENT DELEGATABLE AGENT CONTRACTS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='*.test.ts' --exclude='*.test.mjs' \
  --include='*.ts' --include='*.mjs' \
  -B25 -A80 \
  '(\["cade",[[:space:]]*"effie",[[:space:]]*"atlas"\]|cade\|effie\|atlas|invalid_target)' \
  server db \
  2>/dev/null | head -n 4000 || true

printf '\n=== MATILDA / CADE / EFFIE / ATLAS ROLE EVIDENCE ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='*.test.ts' --exclude='*.test.mjs' \
  --include='*.ts' --include='*.mjs' \
  -B25 -A80 \
  '(agent:[[:space:]]*"(matilda|cade|effie|atlas)"|target:[[:space:]]*"(matilda|cade|effie|atlas)"|assigned_agent|delegation_authorized)' \
  server db \
  2>/dev/null | head -n 6000 || true

printf '\n=== DELEGATION CONTRACT LINEAGE ===\n'
git log --follow \
  --date=iso \
  --format='%H %ad %s' \
  -- server/api/tasks-mutations/delegate-taskspec.mjs \
  | head -100 || true

printf '\n=== ATLAS INTRODUCTION INTO DELEGATION CONTRACT ===\n'
git log --all -p -- \
  server/api/tasks-mutations/delegate-taskspec.mjs \
  2>/dev/null | grep -nE \
  '^(commit |Date:|[-+].*(cade|effie|atlas|invalid_target|target must))' \
  | head -n 1600 || true

printf '\n=== CLASSIFICATION ===\n'
echo 'QUESTION_1=IS_DELEGATE_TASKSPEC_CURRENTLY_PRODUCTION_MOUNTED'
echo 'QUESTION_2=IS_CADE_EFFIE_ATLAS_THE_CURRENT_LIVE_DELEGATABLE_SET'
echo 'QUESTION_3=WHERE_DOES_DB_DELEGATE_TASK_PERSIST_OR_FORWARD_AGENT_IDENTITY'
echo 'QUESTION_4=DOES_DB_DELEGATE_TASK_VALIDATE_IDENTITY_OR_TRUST_CALLERS'
echo 'QUESTION_5=IS_MATILDA_OUTSIDE_THE_DELEGATABLE_AGENT_SET_BY_DESIGN'
echo 'QUESTION_6=IS_THERE_ANY_SINGLE_CURRENT_CANONICAL_AGENT_REGISTRY'
echo 'IDENTITY_MUTATION_PERFORMED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'AUTHORITY_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== FINAL REPOSITORY STATE ===\n'
git status --short
