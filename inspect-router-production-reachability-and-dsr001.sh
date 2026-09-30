#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== BASELINE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"
echo 'EXPECTED_HEAD=ecdfab6b27ed8a0debc890abd2a3fafdf37a9573'
echo 'MUTATION_AUTHORIZED=NO'

printf '\n=== PRODUCTION IMPORTS OF LEGACY ROUTER ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='*.test.ts' --exclude='*.test.mjs' --exclude='*.spec.ts' \
  --include='*.ts' --include='*.mjs' --include='*.js' \
  '(from ["'\''][^"'\'']*orchestration/router|require\([^)]*orchestration/router|import\([^)]*orchestration/router)' \
  server db scripts client/src \
  2>/dev/null || true

printf '\n=== PRODUCTION CALLS TO routeTask ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='router.ts' \
  --exclude='*.test.ts' --exclude='*.test.mjs' --exclude='*.spec.ts' \
  --include='*.ts' --include='*.mjs' --include='*.js' \
  '\brouteTask\s*\(' \
  server db scripts client/src \
  2>/dev/null || true

printf '\n=== LEGACY ROUTER EXPORT CONSUMERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='router.ts' \
  --include='*.ts' --include='*.mjs' --include='*.js' \
  '\b(AgentId|AgentSnapshot|RouteRequest|RouteResult)\b' \
  server db scripts client/src \
  2>/dev/null || true

printf '\n=== CURRENT PRODUCTION ASSIGNMENT PATH ===\n'
for f in \
  server/ellis/assignment-boundary.ts \
  server/ellis/invocation.ts \
  server/ellis/decision.ts \
  db/governance-lifecycle-composition.ts \
  server/lifecycle/production-lifecycle-entry-point.ts \
  server/lifecycle/production-lifecycle-consumer.ts
do
  if [ -f "$f" ]; then
    echo
    echo "===== $f ====="
    grep -niE -B20 -A80 \
      '(assigned_department|assigned_actor|available_actors|assignment_ready|invokeEllisFromEnvelope|evaluateGovernanceLifecycleAssignmentBoundary|routing_authorized|actor_assignment_authorized|participation_resolution_authorized)' \
      "$f" 2>/dev/null || true
  fi
done

printf '\n=== DSR-001 CURRENT CONSTITUTIONAL TEXT ===\n'
if [ -f docs/governance/HQ_ORGANIZATIONAL_CONSTITUTION.md ]; then
  sed -n '466,525p' docs/governance/HQ_ORGANIZATIONAL_CONSTITUTION.md
fi

printf '\n=== PARTICIPANT-SELECTION IMPLEMENTATION SEARCH ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' --include='*.js' \
  -B20 -A80 \
  '(participant[_ -]?(selection|eligibility|resolution)|assigned_actor|available_actors|worker_claim|worker claim|specialization[_ -]?resolution)' \
  server db \
  2>/dev/null | head -n 12000 || true

printf '\n=== ROUTER HISTORY AFTER CONSTITUTION INTRODUCTION ===\n'
git log --all \
  --date=iso \
  --format='%H %ad %s' \
  -- server/orchestration/router.ts server/orchestration/router.test.ts \
  | head -100 || true

printf '\n=== CONSTITUTION HISTORY ===\n'
git log --all \
  --date=iso \
  --format='%H %ad %s' \
  -- docs/governance/HQ_ORGANIZATIONAL_CONSTITUTION.md \
  | head -100 || true

printf '\n=== CAPABILITY MODEL HISTORY ===\n'
git log --all \
  --date=iso \
  --format='%H %ad %s' \
  -- docs/governance/CAPABILITY_ROUTING_MODEL.md \
  | head -100 || true

printf '\n=== DECISION MATRIX ===\n'
echo 'IF_NO_PRODUCTION_CALLER=CLASSIFY_ROUTER_AS_DORMANT_OR_LEGACY_LOCAL_INFRASTRUCTURE'
echo 'IF_PRODUCTION_CALLER_EXISTS=TRACE_CALLER_AUTHORITY_BEFORE_ANY_CHANGE'
echo 'IF_ROUTER_SELECTS_INDIVIDUAL_ACTOR_POST_DEPARTMENT_ASSIGNMENT=CHECK_DSR_001_CONFLICT'
echo 'IF_DSR_001_REMAINS_DEFERRED=DO_NOT_ACTIVATE_PARTICIPANT_SELECTION'
echo 'IF_CURRENT_PRODUCTION_PATH_STOPS_AT_DEPARTMENT=DO_NOT_BRIDGE_TO_AGENT_ROUTER'
echo 'ROUTER_DELETION_AUTHORIZED=NO'
echo 'ROUTER_DEPRECATION_AUTHORIZED=NO'
echo 'ROUTER_RESCOPING_AUTHORIZED=NO'
echo 'PARTICIPANT_RESOLUTION_IMPLEMENTATION_AUTHORIZED=NO'
echo 'AUTHORITY_EXPANSION=NO'

printf '\n=== FINAL QUESTIONS ===\n'
echo 'Q1=DOES_LEGACY_ROUTER_HAVE_ANY_CURRENT_PRODUCTION_CALLER'
echo 'Q2=IS_AGENT_ID_USED_OUTSIDE_LEGACY_ROUTER_AND_TESTS'
echo 'Q3=DOES_CURRENT_PRODUCTION_LIFECYCLE_STOP_AT_DEPARTMENT_ASSIGNMENT'
echo 'Q4=IS_ACTOR_SELECTION_STILL_EXPLICITLY_DEFERRED_BY_DSR_001'
echo 'Q5=WOULD_WIRING_LEGACY_ROUTER_NOW_CROSS_THE_DEFERRED_PARTICIPATION_BOUNDARY'
echo 'Q6=CAN_LEGACY_ROUTER_BE_CLASSIFIED_WITHOUT_MUTATION'

printf '\n=== FINAL REPOSITORY STATE ===\n'
git status --short
