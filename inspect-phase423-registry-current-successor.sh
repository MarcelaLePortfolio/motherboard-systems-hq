#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== BASELINE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"

printf '\n=== PHASE 423 COMMITS: EXACT FILES ===\n'
for commit in \
  ed0cf484e71807732253100ad3c9da2cffc43a76 \
  d4fe82b496c27273888cc027146df72634e4f6f9 \
  c1416eaa4f572092c6ebc06b910b30cf152e704a \
  0d6a124eafa3a55a70e520857280b862fd079e68
do
  echo
  echo "===== $commit ====="
  git show --name-status --format='COMMIT=%H%nDATE=%ad%nSUBJECT=%s' \
    --date=iso "$commit" 2>/dev/null || true
done

printf '\n=== PHASE 423 REGISTRY CONTENT ===\n'
for commit in \
  ed0cf484e71807732253100ad3c9da2cffc43a76 \
  d4fe82b496c27273888cc027146df72634e4f6f9 \
  c1416eaa4f572092c6ebc06b910b30cf152e704a \
  0d6a124eafa3a55a70e520857280b862fd079e68
do
  echo
  echo "===== $commit ====="
  git show "$commit" 2>/dev/null | grep -Ei -B50 -A220 \
    '(registry|canonical|authority|source.of.truth|agent|identity|filesystem|read authority|write authority)' \
    | head -n 5000 || true
done

printf '\n=== FILES TOUCHED BY PHASE 423: CURRENT EXISTENCE ===\n'
{
  for commit in \
    ed0cf484e71807732253100ad3c9da2cffc43a76 \
    d4fe82b496c27273888cc027146df72634e4f6f9 \
    c1416eaa4f572092c6ebc06b910b30cf152e704a \
    0d6a124eafa3a55a70e520857280b862fd079e68
  do
    git diff-tree --no-commit-id --name-only -r "$commit" 2>/dev/null
  done
} | sort -u | while IFS= read -r path; do
  [ -n "$path" ] || continue
  if [ -e "$path" ]; then
    printf 'CURRENT\t%s\n' "$path"
  else
    printf 'ABSENT\t%s\n' "$path"
  fi
done

printf '\n=== PHASE 423 FILE SUCCESSOR HISTORY ===\n'
{
  for commit in \
    ed0cf484e71807732253100ad3c9da2cffc43a76 \
    d4fe82b496c27273888cc027146df72634e4f6f9 \
    c1416eaa4f572092c6ebc06b910b30cf152e704a \
    0d6a124eafa3a55a70e520857280b862fd079e68
  do
    git diff-tree --no-commit-id --name-only -r "$commit" 2>/dev/null
  done
} | sort -u | while IFS= read -r path; do
  [ -n "$path" ] || continue
  echo
  echo "===== $path ====="
  git log --follow --date=iso \
    --format='%H %ad %s' -- "$path" 2>/dev/null | head -n 250 || true
done

printf '\n=== CURRENT IMPORTERS / CALLERS OF REGISTRY ARTIFACTS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' --include='*.js' \
  -B35 -A120 \
  '(agent.?registry|registry.?authority|loadAgents|loadAgent|readRegistry|writeRegistry|registryReader|registryWriter|agent pool|agentPool)' \
  server db scripts client/src \
  2>/dev/null | head -n 12000 || true

printf '\n=== CURRENT SERVER MOUNTS / BOOTSTRAP ===\n'
grep -nEi -B30 -A100 \
  '(registry|agent|orchestrat|router|pool)' \
  server/index.ts 2>/dev/null | head -n 6000 || true

printf '\n=== HISTORICAL AGENT DEFINITIONS AT REGISTRY ERA ===\n'
for commit in \
  ed0cf484e71807732253100ad3c9da2cffc43a76 \
  d4fe82b496c27273888cc027146df72634e4f6f9 \
  c1416eaa4f572092c6ebc06b910b30cf152e704a \
  0d6a124eafa3a55a70e520857280b862fd079e68
do
  echo
  echo "===== $commit ====="
  git grep -niE \
    '(matilda|cade|effie|atlas|ellis|bastion|stryxx)' \
    "$commit" -- \
    'agents/**' 'server/**' 'db/**' 'config/**' 'docs/**' \
    2>/dev/null | head -n 5000 || true
done

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=WHAT_EXACT_ARTIFACT_DID_PHASE423_DECLARE_REGISTRY_AUTHORITY'
echo 'QUESTION_2=WAS_THAT_ARTIFACT_A_CANONICAL_AGENT_IDENTITY_SOURCE_OR_ONLY_OPERATIONAL_REGISTRY'
echo 'QUESTION_3=DOES_THAT_ARTIFACT_EXIST_CURRENTLY'
echo 'QUESTION_4=IF_REMOVED_WHAT_COMMIT_REPLACED_OR_SUPERSEDED_IT'
echo 'QUESTION_5=WHAT_CURRENT_RUNTIME_READS_THE_SUCCESSOR'
echo 'QUESTION_6=WHAT_IDENTITIES_ARE_ACTUALLY_DEFINED_BY_THE_AUTHORITATIVE_SOURCE'
echo 'QUESTION_7=DOES_ELLIS_APPEAR_IN_THAT_SOURCE_OR_ITS_SUCCESSOR'
echo 'QUESTION_8=DO_BASTION_OR_STRYXX_APPEAR_IN_THAT_SOURCE_OR_ITS_SUCCESSOR'
echo 'QUESTION_9=IS_ROUTER_AGENT_ID_ONLY_A_LOCAL_CONSUMER_CONTRACT'
echo 'QUESTION_10=CAN_WE_NOW_NAME_A_SINGLE_CURRENT_CANONICAL_IDENTITY_SOURCE'
echo 'ROUTER_ALLOWLIST_MUTATION=NO'
echo 'IDENTITY_MUTATION=NO'
echo 'AUTHORITY_MUTATION=NO'
echo 'RUNTIME_MUTATION=NO'
echo 'WORKTREE_CLEANUP=NO'

printf '\n=== FINAL REPOSITORY STATE ===\n'
git status --short
