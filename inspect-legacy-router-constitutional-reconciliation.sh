#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== RECONCILIATION BASELINE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"
echo 'IDENTITY_TAXONOMY_FINDING=CAPABILITY_TO_DEPARTMENT_TO_INTERNAL_PARTICIPANT'
echo 'ELLIS_CLASSIFICATION=OPERATIONS_COORDINATION_AUTHORITY'
echo 'ELLIS_GENERIC_ROUTER_AGENT_ID=NOT_SUPPORTED'
echo 'GENERIC_AGENT_ID_AS_CANONICAL_IDENTITY_REGISTRY=NOT_SUPPORTED'
echo 'DSR_001_PARTICIPATION_RESOLUTION=DEFERRED'
echo 'MUTATION_AUTHORIZED=NO'

printf '\n=== LEGACY ROUTER CURRENT CONTRACT ===\n'
sed -n '1,240p' server/orchestration/router.ts 2>/dev/null || true

printf '\n=== LEGACY ROUTER TEST CONTRACT ===\n'
sed -n '1,280p' server/orchestration/router.test.ts 2>/dev/null || true

printf '\n=== ROUTER CREATION LINEAGE ===\n'
git show --stat --oneline c57fa6151821ce80418061ec1dc0eaad43fc17d0 2>/dev/null || true
git show c57fa6151821ce80418061ec1dc0eaad43fc17d0 \
  -- server/orchestration/router.ts server/orchestration/router.test.ts \
  2>/dev/null || true

printf '\n=== ALL PRODUCTION ROUTER IMPORTS AND CALLERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='*.test.ts' --exclude='*.test.mjs' --exclude='*.spec.ts' \
  '(from ["'\''].*orchestration/router|require\(.*orchestration/router|routeTask\()' \
  server db client/src scripts \
  2>/dev/null | head -n 5000 || true

printf '\n=== AGENT ID CONSUMERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  '(AgentId|AgentSnapshot|assignedAgent)' \
  server db client/src scripts \
  2>/dev/null | head -n 6000 || true

printf '\n=== CANONICAL CAPABILITY ROUTING MODEL ===\n'
sed -n '1,360p' docs/governance/CAPABILITY_ROUTING_MODEL.md 2>/dev/null || true

printf '\n=== CONSTITUTIONAL DEPARTMENT AND PARTICIPATION MODEL ===\n'
sed -n '360,530p' docs/governance/HQ_ORGANIZATIONAL_CONSTITUTION.md 2>/dev/null || true

printf '\n=== ORGANIZATIONAL CHARTER ELLIS / CADE / EFFIE ===\n'
sed -n '120,290p' docs/governance/HEADQUARTERS_ORGANIZATIONAL_CHARTER.md 2>/dev/null || true

printf '\n=== CURRENT ELLIS RUNTIME BOUNDARY ===\n'
for f in \
  server/ellis/assignment-boundary.ts \
  server/ellis/invocation.ts \
  server/ellis/decision.ts \
  server/ellis/lifecycle-transition-authorization.ts
do
  if [ -f "$f" ]; then
    echo
    echo "===== $f ====="
    sed -n '1,320p' "$f"
  fi
done

printf '\n=== SEARCH FOR PARTICIPANT RESOLUTION IMPLEMENTATION ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' --include='*.md' \
  -B20 -A80 \
  '(participation resolution|participant selection|participant eligibility|internal participant|DSR-001|worker claim|specialization resolution)' \
  server db docs \
  2>/dev/null | head -n 10000 || true

printf '\n=== ROUTER VS CONSTITUTION HISTORY ===\n'
echo '--- router history ---'
git log --all \
  --date=iso \
  --format='%H %ad %s' \
  -- server/orchestration/router.ts server/orchestration/router.test.ts \
  | head -100 || true

echo
echo '--- capability model history ---'
git log --all \
  --date=iso \
  --format='%H %ad %s' \
  -- docs/governance/CAPABILITY_ROUTING_MODEL.md \
  | head -100 || true

echo
echo '--- constitution history ---'
git log --all \
  --date=iso \
  --format='%H %ad %s' \
  -- docs/governance/HQ_ORGANIZATIONAL_CONSTITUTION.md \
  | head -100 || true

printf '\n=== RECONCILIATION QUESTIONS ===\n'
echo 'Q1=IS_SERVER_ORCHESTRATION_ROUTER_STILL_ON_A_PRODUCTION_PATH'
echo 'Q2=DOES_ROUTER_PREDATE_THE_CAPABILITY_DEPARTMENT_CONSTITUTION'
echo 'Q3=IS_AGENT_ID_A_LEGACY_LOCAL_RUNTIME_TYPE_RATHER_THAN_CANONICAL_IDENTITY'
echo 'Q4=DOES_CURRENT_PRODUCTION_ROUTING_TERMINATE_AT_DEPARTMENT_ASSIGNMENT'
echo 'Q5=WOULD_USING_LEGACY_ROUTER_FOR_ACTOR_SELECTION_PREMATURELY_IMPLEMENT_DSR_001'
echo 'Q6=IS_ROUTER_CURRENTLY_DORMANT_TEST_ONLY_OR_COMPATIBILITY_INFRASTRUCTURE'
echo 'Q7=SHOULD_ROUTER_BE_PRESERVED_DEPRECATED_RESCOPED_OR_RECONCILED_LATER'
echo 'Q8=IS_ANY_RUNTIME_MUTATION_NEEDED_NOW'
echo
echo 'EXPECTED_SAFE_DEFAULT=NO_RUNTIME_MUTATION_UNTIL_RECONCILIATION_IS_COMPLETE'
echo 'ELLIS_ALLOWLIST_MUTATION=NO'
echo 'ELLIS_ROUTER_MUTATION=NO'
echo 'IDENTITY_REGISTRY_CREATION=NO'
echo 'PARTICIPANT_RESOLUTION_IMPLEMENTATION=NO'
echo 'AUTHORITY_EXPANSION=NO'

printf '\n=== FINAL REPOSITORY STATE ===\n'
git status --short
