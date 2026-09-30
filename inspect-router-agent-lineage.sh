#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== CURRENT DETERMINATION ===\n'
echo 'PHASE18_STORE_IS_GENERIC_INFRASTRUCTURE=YES'
echo 'PHASE18_STORE_PERSISTED_AGENT_REGISTRY=NO'
echo 'ELLIS_CANONICAL_AGENT=NOT_ESTABLISHED'
echo 'BASTION_CANONICAL_AGENT=NOT_ESTABLISHED'
echo 'STRYXX_CANONICAL_AGENT=NOT_ESTABLISHED'
echo 'EXPLICIT_AGENT_ID_UNION=MATILDA_CADE_EFFIE_ATLAS_UNKNOWN'

printf '\n=== CURRENT ROUTER CONTRACT ===\n'
sed -n '1,260p' server/orchestration/router.ts 2>/dev/null || true

printf '\n=== ROUTER TESTS ===\n'
sed -n '1,360p' server/orchestration/router.test.ts 2>/dev/null || true

printf '\n=== AGENT-ID INTRODUCTION COMMIT ===\n'
git show --stat --oneline c57fa6151 2>/dev/null || true
git show c57fa6151 -- server/orchestration/router.ts server/orchestration/router.test.ts 2>/dev/null || true

printf '\n=== ROUTER CALLERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  '(routeTask|assignedAgent|from.*orchestration/router|orchestration/router)' \
  server db client/src scripts \
  2>/dev/null | head -n 1000 || true

printf '\n=== ATLAS INTRODUCTION INTO AGENT-ID UNION ===\n'
git log --all -S'"atlas"' \
  --date=iso \
  --format='%H %ad %s' \
  -- server/orchestration/router.ts | head -100 || true

printf '\n=== MATILDA / CADE / EFFIE / ATLAS ROUTING SEMANTICS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  '(assignedAgent.*(matilda|cade|effie|atlas)|(matilda|cade|effie|atlas).*assignedAgent|id:.*(matilda|cade|effie|atlas))' \
  server/orchestration server/orchestrator \
  2>/dev/null | head -n 800 || true

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=WAS_AGENT_ID_UNION_INTENDED_AS_CANONICAL_IDENTITY_OR_ONLY_ROUTER_TARGET_TYPE'
echo 'QUESTION_2=WHEN_AND_WHY_WAS_ATLAS_ADDED'
echo 'QUESTION_3=DO_CALLERS_TREAT_ASSIGNED_AGENT_AS_EXECUTABLE_IDENTITY'
echo 'QUESTION_4=IS_ANY_OTHER_CURRENT_ENTITY_ROUTABLE_AS_AN_AGENT'
echo 'IDENTITY_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== REPOSITORY STATE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"
git status --short
