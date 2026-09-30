#!/usr/bin/env bash
set -u

ROOT="/Users/marcela-dev/Projects/motherboard-systems-hq-clean"
cd "$ROOT" || exit 1

printf '\n=== CURRENT EVIDENCE ===\n'
echo 'ATLAS_EXPLICIT_AGENT_ID=YES'
echo 'ATLAS_DELEGATION_TARGET=YES'
echo 'MATILDA_CADE_EFFIE_COMPILER_AGENT_MEMBERSHIP=YES'
echo 'CHIEF_OF_STAFF_IDENTITY=NOT_ESTABLISHED'

printf '\n=== AGENT IDENTITY SURFACES ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  '(type Agent(Id)?|AgentId|agent registry|agent_registry|available_actors|assignedAgent|assigned_agent)' \
  server db client/src docs scripts 2>/dev/null | head -n 600 || true

printf '\n=== ALL FOUR NAMED ENTITIES ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  '(matilda|cade|effie|atlas)' \
  server/orchestration server/execution server/atlas server/ellis docs/contracts docs/checkpoints \
  2>/dev/null | head -n 800 || true

printf '\n=== OTHER POSSIBLE SYSTEM ENTITIES ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  '(ellis|bastion|stryxx|validator|orchestrator|scheduler|reflection|ops)' \
  server db docs/contracts docs/checkpoints scripts \
  2>/dev/null | head -n 800 || true

printf '\n=== CLASSIFICATION BOUNDARY ===\n'
echo 'AGENT_TYPE_DOES_NOT_IMPLY_EXECUTION_AUTHORITY=YES'
echo 'ROUTING_TARGET_DOES_NOT_IMPLY_CANONICAL_AGENT_IDENTITY=YES'
echo 'MATILDA_EQUALS_CHIEF_OF_STAFF=NO'
echo 'MUTATION_PERFORMED_BY_INSPECTION=NO'

printf '\n=== REPOSITORY STATE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"
git status --short
