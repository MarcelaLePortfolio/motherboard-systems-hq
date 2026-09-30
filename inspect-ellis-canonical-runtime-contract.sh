#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== CONCLUSION ===\n'
echo 'ELLIS_CANONICAL_LIFECYCLE_AUTHORITY=PROVEN'
echo 'ELLIS_IMPLEMENTED_DECISION_INTERFACE=HISTORICALLY_PROVEN'
echo 'ELLIS_IMPLEMENTED_INVOCATION_ADAPTER=HISTORICALLY_PROVEN'
echo 'ELLIS_GENERIC_DELEGATION_TARGET=CURRENTLY_EXCLUDED'
echo 'GENERIC_DELEGATION_TARGETS=CADE_EFFIE_ATLAS'
echo 'NEXT_STEP=INSPECT_EXACT_ELLIS_RUNTIME_CONTRACT_AND_CURRENT_SUCCESSORS'

printf '\n=== ELLIS DECISION INTERFACE COMMIT ===\n'
git show --stat --oneline 2e9b7aa8a0c93289269f3ad408698c7b9979d337 2>/dev/null || true
git show --format=fuller \
  2e9b7aa8a0c93289269f3ad408698c7b9979d337 \
  2>/dev/null | head -n 12000 || true

printf '\n=== ELLIS INVOCATION ADAPTER COMMIT ===\n'
git show --stat --oneline 8fa8c25d78ceaa450e744bd3ee24e487ca137610 2>/dev/null || true
git show --format=fuller \
  8fa8c25d78ceaa450e744bd3ee24e487ca137610 \
  2>/dev/null | head -n 12000 || true

printf '\n=== GOVERNANCE ASSIGNMENT BOUNDARY COMMIT ===\n'
git show --stat --oneline a09a1062894e3a8747e984154c90e2e847df744b 2>/dev/null || true
git show --format=fuller \
  a09a1062894e3a8747e984154c90e2e847df744b \
  2>/dev/null | head -n 14000 || true

printf '\n=== CURRENT SURVIVORS OF THOSE COMMITS ===\n'
for commit in \
  2e9b7aa8a0c93289269f3ad408698c7b9979d337 \
  8fa8c25d78ceaa450e744bd3ee24e487ca137610 \
  a09a1062894e3a8747e984154c90e2e847df744b
do
  echo
  echo "===== $commit ====="

  while IFS= read -r path; do
    [ -z "$path" ] && continue

    if [ -e "$path" ]; then
      echo
      echo "----- CURRENT: $path -----"
      sed -n '1,500p' "$path" 2>/dev/null || true
    else
      echo "CURRENT_ABSENT=$path"
    fi
  done < <(
    git diff-tree --no-commit-id --name-only -r "$commit" 2>/dev/null
  )
done

printf '\n=== CURRENT ELLIS CALL GRAPH ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' --include='*.js' \
  -B30 -A140 \
  '(from .*ellis|import .*ellis|EllisDecision|ellisDecision|invokeEllis|ellisInvocation|ellis.*decision|decision.*ellis)' \
  server db scripts \
  2>/dev/null | head -n 18000 || true

printf '\n=== CURRENT GENERIC DELEGATION CONTRACT ===\n'
sed -n '62,190p' server/api/tasks-mutations/delegate-taskspec.mjs 2>/dev/null || true

printf '\n=== WAS ELLIS EVER A GENERIC DELEGATION TARGET ===\n'
for commit in $(git rev-list --all -- server/api/tasks-mutations/delegate-taskspec.mjs 2>/dev/null); do
  content="$(git show "${commit}:server/api/tasks-mutations/delegate-taskspec.mjs" 2>/dev/null || true)"

  if printf '%s\n' "$content" | grep -qiE \
    '(\["cade",[[:space:]]*"effie",[[:space:]]*"atlas",[[:space:]]*"ellis"|target.{0,120}ellis|agent.{0,120}ellis)'; then
    echo
    echo "===== POSSIBLE GENERIC ELLIS TARGET: $commit ====="
    git show -s --date=iso --format='DATE=%ad%nSUBJECT=%s' "$commit"
    printf '%s\n' "$content" |
      grep -niE -B15 -A30 '(ellis|invalid_target|target must be)' || true
  fi
done

printf '\n=== WAS ELLIS EVER IN ROUTER AGENT ID ===\n'
for commit in $(git rev-list --all -- server/orchestration/router.ts 2>/dev/null); do
  content="$(git show "${commit}:server/orchestration/router.ts" 2>/dev/null || true)"

  if printf '%s\n' "$content" | grep -qiE 'AgentId[^;]*ellis'; then
    echo
    echo "===== ELLIS ROUTER ID: $commit ====="
    git show -s --date=iso --format='DATE=%ad%nSUBJECT=%s' "$commit"
    printf '%s\n' "$content" |
      grep -niE -B10 -A20 '(AgentId|ellis)' || true
  fi
done

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=WHAT_RUNTIME_CONTRACT_DID_ELLIS_DECISION_INTERFACE_DEFINE'
echo 'QUESTION_2=WHAT_RUNTIME_CONTRACT_DID_ELLIS_INVOCATION_ADAPTER_DEFINE'
echo 'QUESTION_3=DO_THESE_COMPONENTS_STILL_EXIST_OR_HAVE_CURRENT_SUCCESSORS'
echo 'QUESTION_4=WAS_ELLIS_EVER_A_GENERIC_DELEGATION_TARGET'
echo 'QUESTION_5=WAS_ELLIS_EVER_A_GENERIC_ROUTER_AGENT'
echo 'QUESTION_6=IS_ELLIS_A_SPECIALIZED_LIFECYCLE_AGENT_AUTHORITY_RATHER_THAN_GENERIC_ROUTER_TARGET'
echo 'IDENTITY_MUTATION=NO'
echo 'ROUTER_MUTATION=NO'
echo 'ALLOWLIST_MUTATION=NO'
echo 'AUTHORITY_MUTATION=NO'
echo 'RUNTIME_MUTATION=NO'

printf '\n=== REPOSITORY STATE ===\n'
git status --short
