#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

CANDIDATE="scripts/run-single-post-fix-validation.sh"
SOURCE="scripts/run-dashboard-generation-control-comparison.ts"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=dadbdd0f' \
  'ISSUE_RESOLVED=NO' \
  'ACTION=CLASSIFY_EXISTING_POST_FIX_VALIDATION_RUNNER_FOR_POST_TIMEOUT_REUSE' \
  'NEW_OLLAMA_INVOCATION=NO' \
  'PRODUCTION_CHANGE=NO' \
  'VALIDATION_AUTHORIZATION_REMAINS_AVAILABLE=YES'

printf '\n=== CANDIDATE RUNNER ===\n'
if [[ -f "$CANDIDATE" ]]; then
  printf '%s\n' \
    'CANDIDATE_RUNNER_PRESENT=YES' \
    "CANDIDATE_RUNNER=$CANDIDATE"
  sed -n '1,180p' "$CANDIDATE"
else
  printf '%s\n' 'CANDIDATE_RUNNER_PRESENT=NO'
fi

printf '\n=== SOURCE RUNNER EXACT REQUEST ===\n'
grep -n -A5 -B3 \
  'Create a simple internal status dashboard for tracking three workstreams' \
  "$SOURCE" || true

printf '\n=== CANDIDATE EXECUTION SHAPE ===\n'
grep -nE \
  'SOURCE=|TMP=|RESULT=|UNSEEDED_RUNS|CONTROLLED_RUNS|npx tsx|validationGenerationSeed|run-dashboard-generation-control-comparison' \
  "$CANDIDATE" 2>/dev/null || true

printf '\n=== CURRENT SOURCE RUNNER SHAPE ===\n'
grep -nE \
  'const UNSEEDED_RUNS|const CONTROLLED_RUNS|CONTROLLED_SEED|validationGenerationSeed|ollamaChat\(' \
  "$SOURCE" || true

printf '\n=== CURRENT TIMEOUT ===\n'
grep -n -A2 -B1 \
  'OLLAMA_CHAT_TIMEOUT_MS' \
  scripts/utils/ollamaChat.ts || true

printf '\n=== CLASSIFICATION ===\n'
if [[ -f "$CANDIDATE" ]] \
  && grep -q 'run-dashboard-generation-control-comparison.ts' "$CANDIDATE" \
  && grep -q 'const UNSEEDED_RUNS = 1;' "$CANDIDATE" \
  && grep -q 'const CONTROLLED_RUNS = 0;' "$CANDIDATE"; then
  printf '%s\n' \
    'EXISTING_RUNNER_REUSES_DASHBOARD_COMPARISON_SOURCE=YES' \
    'EXISTING_RUNNER_SINGLE_UNSEEDED_INVOCATION=YES' \
    'EXISTING_RUNNER_CONTROLLED_INVOCATIONS=ZERO' \
    'EXACT_DASHBOARD_REQUEST_IN_SOURCE=YES' \
    'POST_TIMEOUT_REUSE_READINESS=SUPPORTED' \
    'NEXT_ACTION=REPOINT_AUTHORIZED_POST_TIMEOUT_WRAPPER_TO_EXISTING_RUN_SINGLE_POST_FIX_VALIDATION_RUNNER_WITHOUT_CHANGING_RUNTIME'
else
  printf '%s\n' \
    'POST_TIMEOUT_REUSE_READINESS=NOT_ESTABLISHED' \
    'NEXT_ACTION=RECONSTRUCT_EXACT_SINGLE_INVOCATION_RUNNER_FROM_CURRENT_DASHBOARD_COMPARISON_SOURCE_WITHOUT_STARTING_OLLAMA'
fi

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'AUTHORIZED_OLLAMA_INVOCATION_CONSUMED=NO' \
  'OLLAMA_REQUEST_STARTED=NO' \
  'DASHBOARD_SMOKE_TEST_STARTED=NO' \
  'TIMEOUT_CHANGED_AGAIN=NO' \
  'PROMPT_CHANGED=NO' \
  'VALIDATOR_CHANGED=NO' \
  'MODEL_CHANGED=NO' \
  'RETRY_CHANGED=NO' \
  'GENERATION_POLICY_CHANGED=NO'

printf '\n=== WORKTREE ===\n'
git status --short
