#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== BASELINE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"

printf '\n=== ROUTER IMPLEMENTATION ===\n'
sed -n '1,280p' server/orchestration/router.ts 2>/dev/null || true

printf '\n=== PRODUCTION ROUTETASK CALLERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='*.test.ts' --exclude='*.test.mjs' \
  --include='*.ts' --include='*.mjs' \
  -B25 -A60 \
  '(routeTask\(|orchestration/router)' \
  server db scripts \
  2>/dev/null || true

printf '\n=== ASSIGNED AGENT PRODUCER / CONSUMER CHAIN ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='*.test.ts' --exclude='*.test.mjs' \
  --include='*.ts' --include='*.mjs' \
  -B25 -A60 \
  '(assignedAgent|assigned_agent)' \
  server db scripts \
  2>/dev/null | head -n 4000 || true

printf '\n=== AGENT SNAPSHOT PRODUCERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' \
  -B25 -A60 \
  '(AgentSnapshot|agents:[[:space:]]|agents =|requiredCaps|caps:)' \
  server db scripts \
  2>/dev/null | head -n 3500 || true

printf '\n=== CURRENT SERVER MOUNTS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' \
  -B20 -A50 \
  '(matilda-routing-route|matilda-assignment-route|matilda-execution-planning-route|orchestration/router|orchestrator)' \
  server/index.ts server \
  2>/dev/null | head -n 3500 || true

printf '\n=== LEGACY ROUTE IMPORT PROOF ===\n'
for name in \
  matilda-routing-route \
  matilda-assignment-route \
  matilda-execution-planning-route
do
  echo
  echo "--- $name ---"
  grep -Rni \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
    --exclude="${name}.ts" \
    --include='*.ts' --include='*.mjs' \
    "$name" server db scripts 2>/dev/null || true
done

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=IS_ORCHESTRATION_ROUTER_PRODUCTION_LIVE'
echo 'QUESTION_2=WHAT_RUNTIME_SUPPLIES_AGENT_SNAPSHOTS'
echo 'QUESTION_3=WHERE_IS_ASSIGNED_AGENT_FIRST_DERIVED_IN_CURRENT_LIVE_RUNTIME'
echo 'QUESTION_4=DOES_ASSIGNED_AGENT_FLOW_INTO_GOVERNED_EXECUTION'
echo 'QUESTION_5=ARE_MATILDA_ROUTING_AND_ASSIGNMENT_ROUTES_CURRENTLY_MOUNTED'
echo 'QUESTION_6=IS_EXECUTION_PLANNING_ROUTE_CURRENTLY_MOUNTED'
echo 'QUESTION_7=WHICH_CURRENT_SURFACE_CAN_ACTUALLY_DEFINE_CANONICAL_AGENT_IDENTITY'
echo 'IDENTITY_MUTATION_PERFORMED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'AUTHORITY_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== FINAL REPOSITORY STATE ===\n'
git status --short
