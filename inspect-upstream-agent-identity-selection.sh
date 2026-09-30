#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== ROUTING ENDPOINT CALLERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B50 -A120 \
  '(/api/matilda/routing|matilda/routing|createRouting\()' \
  server db client/src scripts \
  2>/dev/null | head -n 9000 || true

printf '\n=== ASSIGNMENT ENDPOINT CALLERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B50 -A120 \
  '(/api/matilda/assignment|matilda/assignment|createAssignment\()' \
  server db client/src scripts \
  2>/dev/null | head -n 9000 || true

printf '\n=== EXECUTION PLANNING ENDPOINT CALLERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B50 -A120 \
  '(/api/matilda/execution-planning|matilda/execution-planning|createExecutionPlan\()' \
  server db client/src scripts \
  2>/dev/null | head -n 9000 || true

printf '\n=== IDENTITY SELECTION EXPRESSIONS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B35 -A100 \
  '(routing_destination[[:space:]]*[:=]|assigned_agent[[:space:]]*[:=]|assignedAgent[[:space:]]*[:=]|delegation_target[[:space:]]*[:=])' \
  server db client/src scripts \
  2>/dev/null | head -n 12000 || true

printf '\n=== RECONCILIATION IDENTITY REFERENCES ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B40 -A120 \
  '(reconcil.*(agent|actor|identity|assignment|routing)|assigned_agent.*reconcil|routing_destination.*reconcil)' \
  server db scripts \
  2>/dev/null | head -n 12000 || true

printf '\n=== NAMED ENTITY ASSIGNMENT HISTORY ===\n'
for name in matilda cade effie atlas ellis bastion stryxx; do
  echo
  echo "===== $name ====="
  grep -RniE \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
    -B20 -A60 \
    "(routing_destination|assigned_agent|assignedAgent|delegation_target).*[\"']${name}[\"']|[\"']${name}[\"'].*(routing_destination|assigned_agent|assignedAgent|delegation_target)" \
    server db client/src scripts \
    2>/dev/null | head -n 1500 || true
done

printf '\n=== HISTORICAL IDENTITY-SELECTION COMMITS ===\n'
git log --all \
  --date=iso \
  --format='%H %ad %s' \
  -G'(routing_destination|assigned_agent|assignedAgent|delegation_target)' \
  -- server db scripts \
  | head -n 500 || true

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'CURRENT_DURABLE_EXECUTION_AGENT_VALUES=cade_only'
echo 'ASSIGNMENT_RUNTIME_CANONICAL_REGISTRY=NO'
echo 'EXECUTION_PLANNING_RUNTIME_CANONICAL_REGISTRY=NO'
echo 'ROUTING_RUNTIME_GRANTS_ASSIGNMENT_AUTHORITY=NO'
echo 'QUESTION_1=WHO_OR_WHAT_SELECTS_ROUTING_DESTINATION'
echo 'QUESTION_2=WHO_OR_WHAT_CONVERTS_ROUTING_DESTINATION_TO_ASSIGNED_AGENT'
echo 'QUESTION_3=DOES_RECONCILIATION_DEFINE_OR_VALIDATE_AGENT_IDENTITY'
echo 'QUESTION_4=ARE_ANY_IDENTITIES_OTHER_THAN_CADE_PRODUCTION_ASSIGNMENT_TARGETS'
echo 'QUESTION_5=IS_THERE_A_DISTINCT_CANONICAL_AGENT_REGISTRY_ELSEWHERE'
echo 'IDENTITY_MUTATION_PERFORMED=NO'
echo 'DELEGATION_MUTATION_PERFORMED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== REPOSITORY STATE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"
git status --short
