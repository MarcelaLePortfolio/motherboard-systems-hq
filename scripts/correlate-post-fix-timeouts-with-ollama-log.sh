#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

LOG="$HOME/.ollama/logs/server.log"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=7b5bb3da' \
  'ACTION=CORRELATE_POST_FIX_TIMEOUTS_WITH_EXISTING_OLLAMA_LOG' \
  'NEW_OLLAMA_INVOCATION=NO' \
  'PRODUCTION_CHANGE=NO'

printf '\n=== RECENT SERVER LOG WINDOW ===\n'
tail -1200 "$LOG" | grep -nE \
  'prompt processing|n_decoded|prompt eval time|eval time|total time|task [0-9]+|cancel|abort|stop|request|generate' \
  | tail -500 || true

printf '\n=== HIGH-DECODE REQUESTS NEAR TIMEOUT BOUNDARY ===\n'
tail -2500 "$LOG" | grep -E \
  'n_decoded = +1[4-9][0-9][0-9]|n_decoded = +[2-9][0-9][0-9][0-9]|prompt eval time|eval time|total time' \
  | tail -400 || true

printf '\n=== ABORT / CANCELLATION SIGNALS ===\n'
tail -3000 "$LOG" | grep -niE \
  'cancel|cancelled|canceled|abort|aborted|client.*closed|broken pipe|context canceled|stop.*task|slot.*release' \
  | tail -200 || true

printf '\n=== STATIC CORRELATION CLASSIFICATION ===\n'
printf '%s\n' \
  'POST_FIX_TIMEOUT_COUNT=2' \
  'CLIENT_TIMEOUT_MS=60000' \
  'OBSERVED_PROMPT_EVAL_SECONDS_APPROX_10_TO_11=YES' \
  'OBSERVED_GENERATION_RATE_APPROX_33_TO_34_TOKENS_PER_SECOND=YES' \
  'APPROX_DECODE_BUDGET_BEFORE_60S_AFTER_PROMPT_EVAL=1600_TO_1700_TOKENS' \
  'POST_FIX_REQUEST_TO_EXACT_TASK_MAPPING_PENDING_OUTPUT_REVIEW=YES' \
  'THIRD_IDENTICAL_VALIDATION_JUSTIFIED=NO'

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'OLLAMA_GENERATION_STARTED=NO' \
  'TIMEOUT_CHANGED=NO' \
  'MODEL_CHANGED=NO' \
  'VALIDATOR_CHANGED=NO' \
  'PROMPT_CHANGED=NO' \
  'GENERATION_POLICY_CHANGED=NO'

git status --short
