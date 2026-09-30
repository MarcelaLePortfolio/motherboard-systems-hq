#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== PRODUCTION ROUTER CALLERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='*.test.*' \
  -B50 -A140 \
  'routeTask[[:space:]]*\(' \
  server db scripts client/src \
  2>/dev/null | head -n 12000 || true

printf '\n=== AGENT SNAPSHOT SOURCES ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B60 -A160 \
  '(AgentSnapshot|agentSnapshots|agentRegistry|agent_registry|registeredAgents|availableAgents|agents[[:space:]]*[:=])' \
  server db scripts client/src \
  2>/dev/null | head -n 15000 || true

printf '\n=== NAMED PRODUCTION AGENT REFERENCES ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='*.test.*' \
  -B30 -A90 \
  '(["'\'']matilda["'\'']|["'\'']cade["'\'']|["'\'']effie["'\'']|["'\'']atlas["'\'']|["'\'']ellis["'\'']|["'\'']bastion["'\'']|["'\'']stryxx["'\''])' \
  server db scripts client/src \
  2>/dev/null | head -n 18000 || true

printf '\n=== ROUTER TO MATILDA CHAIN CONNECTION ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B50 -A130 \
  '(assignedAgent|assigned_agent|routing_destination|createRouting|createAssignment)' \
  server db \
  2>/dev/null | head -n 16000 || true

printf '\n=== CLASSIFICATION ===\n'
echo 'QUESTION_1=IS_ORCHESTRATION_ROUTER_A_CURRENT_PRODUCTION_PATH'
echo 'QUESTION_2=WHAT_RUNTIME_SOURCE_POPULATES_AGENT_SNAPSHOTS'
echo 'QUESTION_3=ARE_EFFIE_AND_ATLAS_REAL_PRODUCTION_TARGETS_OR_TEST_ONLY'
echo 'QUESTION_4=DOES_ROUTER_CONNECT_TO_CURRENT_MATILDA_ASSIGNMENT_CHAIN'
echo 'QUESTION_5=IS_ANY_ADDITIONAL_ENTITY_CURRENTLY_ASSIGNABLE_AS_AN_AGENT'
echo 'IDENTITY_MUTATION_PERFORMED=NO'
echo 'AUTHORITY_MUTATION_PERFORMED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== REPOSITORY STATE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"
git status --short
