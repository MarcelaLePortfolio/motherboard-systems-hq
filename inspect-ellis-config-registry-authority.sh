#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== CONCLUSION ===\n'
echo 'NEW_CANDIDATE_CANONICAL_IDENTITY_SURFACE=config/agents.json'
echo 'REASON=HISTORICAL_ONBOARDING_CODE_EXPLICITLY_UPSERTED_AGENT_NAME_ROLE_AND_ID_INTO_CONFIG_AGENTS_JSON'
echo 'ELLIS_AGENT_STATUS=STILL_NOT_PROVEN'
echo 'NEXT_STEP=VERIFY_CURRENT_AND_HISTORICAL_CONFIG_REGISTRY_AND_ELLIS_PROMOTION_AGAINST_IT'

printf '\n=== CURRENT CONFIG AGENTS ===\n'
if [ -f config/agents.json ]; then
  cat config/agents.json
else
  echo 'config/agents.json ABSENT'
fi

printf '\n=== CONFIG AGENTS HISTORY ===\n'
git log --all --follow \
  --date=iso \
  --format='COMMIT=%H%nDATE=%ad%nSUBJECT=%s' \
  -- config/agents.json \
  2>/dev/null | head -n 2000 || true

printf '\n=== EVERY HISTORICAL CONFIG AGENTS VERSION CONTAINING ELLIS ===\n'
for commit in $(git rev-list --all -- config/agents.json 2>/dev/null); do
  if git show "${commit}:config/agents.json" 2>/dev/null | grep -qi 'ellis'; then
    echo
    echo "===== COMMIT $commit ====="
    git show -s --date=iso --format='DATE=%ad%nSUBJECT=%s' "$commit"
    git show "${commit}:config/agents.json" 2>/dev/null || true
  fi
done

printf '\n=== ELLIS PROMOTION COMMITS ACROSS FULL REPOSITORY ===\n'
git log --all \
  --date=iso \
  --format='COMMIT=%H%nDATE=%ad%nSUBJECT=%s' \
  -G'([Ee]llis.{0,160}(promot|agent|coordinator|authority|role|reconcil|delegate)|((promot|agent|coordinator|authority|role|reconcil|delegate).{0,160}[Ee]llis))' \
  -- . \
  2>/dev/null | head -n 5000 || true

printf '\n=== ELLIS EXACT CONTENT HISTORY ===\n'
git log --all -S'Ellis' \
  --date=iso \
  --format='%H %ad %s' \
  -- . \
  2>/dev/null | head -n 1000 || true

git log --all -S'ellis' \
  --date=iso \
  --format='%H %ad %s' \
  -- . \
  2>/dev/null | head -n 1000 || true

printf '\n=== CURRENT ELLIS REFERENCES ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='*.bak' \
  -B25 -A80 \
  '[Ee]llis' \
  config server db scripts docs \
  2>/dev/null | head -n 10000 || true

printf '\n=== ONBOARDING REGISTRY CONTRACT ===\n'
sed -n '55,175p' scripts/_local/matilda_tasks/onboard_agent.mjs 2>/dev/null || true

printf '\n=== ONBOARDING FILE HISTORY ===\n'
git log --all --follow \
  --date=iso \
  --format='COMMIT=%H%nDATE=%ad%nSUBJECT=%s' \
  -- scripts/_local/matilda_tasks/onboard_agent.mjs \
  2>/dev/null | head -n 1000 || true

printf '\n=== WHO READS CONFIG AGENTS JSON ===\n'
grep -RniF \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  'config/agents.json' \
  server db scripts client/src config \
  2>/dev/null | head -n 3000 || true

grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  '(agents\.json|CONFIG_PATH).{0,160}(read|load|import|require|agent|runtime|route|delegate)|(read|load|import|require|agent|runtime|route|delegate).{0,160}(agents\.json|CONFIG_PATH)' \
  server db scripts client/src config \
  2>/dev/null | head -n 5000 || true

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=WAS_ELLIS_EVER_REGISTERED_IN_CONFIG_AGENTS_JSON'
echo 'QUESTION_2=DID_ELLIS_PROMOTION_WRITE_OR_RECONCILE_AN_AGENT_IDENTITY_RECORD'
echo 'QUESTION_3=WAS_CONFIG_AGENTS_JSON_INTENDED_AS_IDENTITY_AUTHORITY_OR_ONLY_ONBOARDING_METADATA'
echo 'QUESTION_4=DO_CURRENT_RUNTIME_OR_ROUTING_COMPONENTS_CONSUME_CONFIG_AGENTS_JSON'
echo 'QUESTION_5=IS_THERE_A_SUCCESSOR_REGISTRY_TO_CONFIG_AGENTS_JSON'
echo 'QUESTION_6=CAN_ELLIS_AGENT_STATUS_BE_PROVEN_WITHOUT_MUTATION'
echo 'IDENTITY_MUTATION=NO'
echo 'ROUTER_MUTATION=NO'
echo 'AUTHORITY_MUTATION=NO'
echo 'RUNTIME_MUTATION=NO'

printf '\n=== REPOSITORY STATE ===\n'
git status --short
