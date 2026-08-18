#!/usr/bin/env bash
set -u

echo "=== PHASE 3 / CORRIDOR 2 — CONTRACT CLASSIFICATION STOP DIAGNOSIS ==="

echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short HEAD)"
echo "WORKTREE:"
git status --short

check() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "${label}=PASS"
  else
    echo "${label}=FAIL"
  fi
}

check "EXPECTED_BRANCH" test "$(git branch --show-current)" = "feature/support-source-references-runtime"
check "BASE_21797E7C_IS_ANCESTOR" git merge-base --is-ancestor 21797e7c HEAD
check "PROMPT_EXACT_SELECTION_RULE" grep -Fq \
  "Set selectedContextSegments to exactly the supplied project-context child segments whose content materially affects the immediate reply." \
  scripts/utils/ollamaChat.ts
check "PROMPT_EXACT_IDENTITY_RULE" grep -Fq \
  "Use only the exact relativePath, sourceStartLine, and sourceEndLine supplied for each selected child." \
  scripts/utils/ollamaChat.ts
check "PROMPT_EMPTY_SELECTION_RULE" grep -Fq \
  "Return [] when no supplied project-context child materially affects the immediate reply." \
  scripts/utils/ollamaChat.ts
check "PROMPT_CONVERSATION_INDEPENDENCE_RULE" grep -Fq \
  "Conversation history remains independent and does not require selectedContextSegments membership." \
  scripts/utils/ollamaChat.ts

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-phase-3-corridor-2-cross-cutting-selected-context-contract\.sh$|^ M scripts/classify-phase-3-corridor-2-cross-cutting-selected-context-contract\.sh$|^\?\? scripts/diagnose-phase-3-corridor-2-contract-classification-stop\.sh$|^ M scripts/diagnose-phase-3-corridor-2-contract-classification-stop\.sh$' ||
  true
)"

if [[ -z "$unexpected" ]]; then
  echo "WORKTREE_BOUNDARY=PASS"
else
  echo "WORKTREE_BOUNDARY=FAIL"
  printf '%s\n' "$unexpected"
fi

echo "DIAGNOSIS_ONLY=YES"
echo "NEW_BEHAVIOR_VALIDATION_ATTEMPT=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "DR_NOW=NO"
echo "NEXT_ACTION=CORRECT_ONLY_THE_FAILED_PREREQUISITE_BEFORE_RERUNNING_CONTRACT_CLASSIFICATION"
