#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=a151b1c0' \
  'ACTION=INVESTIGATE_EXISTING_OLLAMA_AND_REQUEST_TELEMETRY_WITHOUT_GENERATION' \
  'NEW_OLLAMA_INVOCATION=NO' \
  'PRODUCTION_CHANGE=NO'

printf '\n=== OLLAMA PROCESS STATE ===\n'
ollama ps || true
ps -axo pid,ppid,etime,stat,%cpu,%mem,command | grep -E '[o]llama|[l]lama-server' || true

printf '\n=== OLLAMA CONNECTION STATE ===\n'
lsof -nP -iTCP:11434 2>/dev/null || true

printf '\n=== OLLAMA LOG CANDIDATES ===\n'
find "$HOME/Library/Logs" "$HOME/.ollama" \
  -maxdepth 4 \
  -type f \
  \( -name '*.log' -o -name '*.txt' \) \
  -print 2>/dev/null | tail -100 || true

printf '\n=== RECENT OLLAMA TIMING TELEMETRY ===\n'
while IFS= read -r file; do
  if grep -qiE \
    'prompt_eval|eval_duration|total_duration|load_duration|prompt eval|generation|timing|duration|timeout' \
    "$file" 2>/dev/null; then
    echo "--- FILE=$file"
    grep -niE \
      'prompt_eval|eval_duration|total_duration|load_duration|prompt eval|generation|timing|duration|timeout' \
      "$file" 2>/dev/null | tail -120 || true
  fi
done < <(
  find "$HOME/Library/Logs" "$HOME/.ollama" \
    -maxdepth 4 \
    -type f \
    \( -name '*.log' -o -name '*.txt' \) \
    -print 2>/dev/null
)

printf '\n=== REQUEST / RESPONSE TELEMETRY IN REPOSITORY ===\n'
grep -RniE \
  'prompt_eval_count|prompt_eval_duration|eval_count|eval_duration|total_duration|load_duration|response.*duration|request.*duration|performance.*ollama' \
  scripts server routes docs/checkpoints \
  2>/dev/null | tail -200 || true

printf '\n=== CURRENT RESPONSE TYPE CONTRACT ===\n'
grep -n -A20 -B5 \
  'interface OllamaGenerateResponse' \
  scripts/utils/ollamaChat.ts || true

printf '\n=== CLASSIFICATION BOUNDARY ===\n'
printf '%s\n' \
  'POST_FIX_TIMEOUT_COUNT=2' \
  'EXACT_GENERATION_DURATION_HISTORY_AVAILABLE=NO' \
  'EXACT_RESPONSE_TOKEN_HISTORY_AVAILABLE=NO' \
  'TELEMETRY_AVAILABILITY_NOT_YET_CLASSIFIED=YES' \
  'THIRD_IDENTICAL_VALIDATION_JUSTIFIED=NO' \
  'NEXT_ACTION=CLASSIFY_WHETHER_EXISTING_TELEMETRY_CAN_SEPARATE_PROMPT_EVALUATION_DELAY_FROM_TOKEN_GENERATION_DELAY'

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'OLLAMA_GENERATION_STARTED=NO' \
  'TIMEOUT_CHANGED=NO' \
  'MODEL_CHANGED=NO' \
  'VALIDATOR_CHANGED=NO' \
  'PROMPT_CHANGED=NO' \
  'GENERATION_POLICY_CHANGED=NO'

printf '\n=== WORKTREE ===\n'
git status --short
