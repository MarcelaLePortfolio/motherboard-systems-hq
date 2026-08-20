#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OLLAMA_FILE="scripts/utils/ollamaChat.ts"
RUNNER="scripts/run-dashboard-generation-control-comparison.ts"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=6ba5c3b8' \
  'ACTION=INVESTIGATE_POST_FIX_TIMEOUT_RUNTIME_BOUNDARY' \
  'NEW_OLLAMA_INVOCATION=NO' \
  'PRODUCTION_CHANGE=NO' \
  'THIRD_VALIDATION_ATTEMPT=NO'

printf '\n=== TIMEOUT IMPLEMENTATION ===\n'
grep -n -A20 -B10 \
  'OLLAMA_CHAT_TIMEOUT_MS\|AbortController\|setTimeout\|timed out' \
  "$OLLAMA_FILE" || true

printf '\n=== REQUEST CONSTRUCTION ===\n'
grep -n -A45 -B20 \
  'fetch(' \
  "$OLLAMA_FILE" || true

printf '\n=== RESPONSE / ABORT HANDLING ===\n'
grep -n -A45 -B20 \
  'controller.abort\|clearTimeout\|response.json\|response.text\|catch' \
  "$OLLAMA_FILE" || true

printf '\n=== VALIDATION RUNNER INVOCATION PATH ===\n'
grep -n -A35 -B15 \
  'ollamaChat(' \
  "$RUNNER" || true

printf '\n=== OLLAMA LOCAL STATE — NO GENERATION ===\n'
ollama ps || true
ps -axo pid,ppid,etime,stat,command | grep -E '[o]llama|[t]sx' || true
lsof -nP -iTCP:11434 2>/dev/null || true

printf '\n=== RESOURCE SNAPSHOT ===\n'
uptime || true
vm_stat || true

printf '\n=== CLASSIFICATION BOUNDARY ===\n'
printf '%s\n' \
  'POST_FIX_TIMEOUT_COUNT=2' \
  'SUPPORT_REFERENCE_FIX_VALIDATED=NO' \
  'SUPPORT_REFERENCE_FIX_DISPROVEN=NO' \
  'TIMEOUT_RUNTIME_CAUSE_ESTABLISHED=NO' \
  'THIRD_IDENTICAL_INVOCATION_JUSTIFIED=NO' \
  'NEXT_ACTION=CLASSIFY_TIMEOUT_PATH_FROM_STATIC_RUNTIME_EVIDENCE_BEFORE_ANY_NEW_INVOCATION_OR_TIMEOUT_CHANGE'

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
