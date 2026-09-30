#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== BASELINE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"

printf '\n=== CURRENT ELLIS REFERENCES ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  '(ellis|ELLIS)' \
  server db client/src scripts docs \
  2>/dev/null | head -n 5000 || true

printf '\n=== ELLIS + PROMOTION / RECONCILIATION / AGENT SEMANTICS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B40 -A140 \
  '(ellis|ELLIS).*(promot|reconcil|agent|identity|role|coordinator|execut|delegat|actor)|(promot|reconcil|agent|identity|role|coordinator|execut|delegat|actor).*(ellis|ELLIS)' \
  server db client/src scripts docs \
  2>/dev/null | head -n 9000 || true

printf '\n=== ELLIS GIT LINEAGE ===\n'
git log --all \
  --date=iso \
  --format='%H %ad %s' \
  -S'Ellis' \
  -- . \
  | head -n 500 || true

printf '\n=== LOWERCASE ELLIS GIT LINEAGE ===\n'
git log --all \
  --date=iso \
  --format='%H %ad %s' \
  -S'ellis' \
  -- . \
  | head -n 500 || true

printf '\n=== PROMOTION COMMITS INVOLVING ELLIS ===\n'
git log --all \
  --date=iso \
  --format='%H %ad %s' \
  --grep='ellis' \
  --grep='promotion' \
  --grep='reconciliation' \
  --regexp-ignore-case \
  | head -n 1000 || true

printf '\n=== HISTORICAL ELLIS IDENTITY DEFINITIONS ===\n'
git grep -niE \
  '(ellis|ELLIS).*(agent|actor|identity|role|coordinator|delegate|execution)|(agent|actor|identity|role|coordinator|delegate|execution).*(ellis|ELLIS)' \
  $(git rev-list --all | head -n 500) \
  -- 'server/**' 'db/**' 'docs/**' 'scripts/**' \
  2>/dev/null | head -n 9000 || true

printf '\n=== RECONCILIATION ARTIFACT NAMES ===\n'
find . \
  -path './node_modules' -prune -o \
  -path './.git' -prune -o \
  -type f \
  \( -iname '*ellis*' -o -iname '*promotion*' -o -iname '*reconciliation*' \) \
  -print 2>/dev/null | sort | head -n 3000 || true

printf '\n=== ELLIS IN AGENT ALLOWLISTS / UNIONS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B25 -A80 \
  '(AgentId|agent_id|agentId|assigned_agent|assignedAgent|target_agent|targetAgent|agents).*(ellis|ELLIS)|(ellis|ELLIS).*(AgentId|agent_id|agentId|assigned_agent|assignedAgent|target_agent|targetAgent|agents)' \
  server db scripts client/src \
  2>/dev/null | head -n 6000 || true

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=WAS_ELLIS_EXPLICITLY_PROMOTED'
echo 'QUESTION_2=WHAT_WAS_ELLIS_PROMOTED_FROM'
echo 'QUESTION_3=WHAT_WAS_ELLIS_PROMOTED_TO'
echo 'QUESTION_4=WAS_THE_PROMOTION_DURABLY_RECONCILED'
echo 'QUESTION_5=DID_RECONCILIATION_CLASSIFY_ELLIS_AS_AGENT'
echo 'QUESTION_6=DID_ELLIS_GAIN_DELEGATION_OR_EXECUTION_ELIGIBILITY'
echo 'QUESTION_7=IS_CURRENT_CADE_EFFIE_ATLAS_ALLOWLIST_INCOMPLETE_RELATIVE_TO_RECONCILED_IDENTITY'
echo 'QUESTION_8=SHOULD_ELLIS_BE_INCLUDED_IN_ANY_FUTURE_CANONICAL_AGENT_REGISTRY'
echo 'DO_NOT_ASSUME_PROMOTION_EQUALS_AGENT_STATUS=YES'
echo 'DO_NOT_MODIFY_CURRENT_AGENT_ALLOWLISTS=YES'
echo 'IDENTITY_MUTATION_PERFORMED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'AUTHORITY_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== FINAL REPOSITORY STATE ===\n'
git status --short
