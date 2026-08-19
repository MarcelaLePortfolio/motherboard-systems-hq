#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=36e14845' \
  'MODE=DIAGNOSTIC_ONLY' \
  'PRODUCTION_CHANGE=NONE' \
  'KNOWN_LOG_FD_TARGET=/private/tmp/motherboard-server-after-ollamachat-fix.log' \
  'KNOWN=PATH_VISIBLE_TO_LSOF_BUT_MISSING_FROM_DIRECTORY' \
  'KNOWN=PREVIOUS_SCRIPT_FAILED_ONLY_BECAUSE_BASH_MAPFILE_IS_UNAVAILABLE' \
  'TARGET=RECOVER_CURRENT_LOG_EVIDENCE_WITH_MACOS_COMPATIBLE_SHELL'

PID="$(lsof -tiTCP:3000 -sTCP:LISTEN | head -1)"

if [[ -z "${PID:-}" ]]; then
  echo 'BACKEND_PID=NOT_FOUND'
  exit 1
fi

echo "BACKEND_PID=$PID"

printf '\n=== VERIFY LIVE OUTPUT DESCRIPTORS ===\n'
lsof -a -p "$PID" -d 1,2 -Fn 2>/dev/null || true

printf '\n=== RESOLVE CURRENT LOG TARGET ===\n'
LOG_PATH="$(
  lsof -a -p "$PID" -d 1 -Fn 2>/dev/null |
  sed -n 's/^n//p' |
  head -1
)"

echo "LOG_PATH=${LOG_PATH:-UNRESOLVED}"

printf '\n=== FILESYSTEM STATUS ===\n'
if [[ -n "${LOG_PATH:-}" && -e "$LOG_PATH" ]]; then
  echo 'LOG_PATH_EXISTS=YES'

  printf '\n=== CURRENT LOG TAIL ===\n'
  tail -200 "$LOG_PATH" || true

  printf '\n=== MATILDA ERROR CONTEXT ===\n'
  grep -n -A40 -B25 -E \
    'Matilda conversation workflow|Conversational response failed|Ollama returned|support reference|selected context|investigation lifecycle|malformed structured|durable interpretation|Error:' \
    "$LOG_PATH" || true
else
  echo 'LOG_PATH_EXISTS=NO'
  echo 'OPEN_DESCRIPTOR_POINTS_TO_UNLINKED_OR_STALE_DIRECTORY_ENTRY=YES'
fi

printf '\n=== PROCESS OUTPUT SNAPSHOT ===\n'
lsof -p "$PID" 2>/dev/null | grep -E ' 1w | 2w ' || true

printf '\n=== WORKFLOW FAILURE TRANSLATION SITE ===\n'
grep -n -A25 -B25 \
  'throw new MatildaConversationWorkflowUnavailableError' \
  server/matilda-chat-workflow.ts || true

printf '\n=== CLASSIFICATION ===\n'
printf '%s\n' \
  'LIVE_503_CONFIRMED=YES' \
  'OLLAMA_SERVICE_FAILURE=NO' \
  'MODEL_MISSING=NO' \
  'PREVIOUS_DIAGNOSTIC_FAILURE=SHELL_COMPATIBILITY_ONLY' \
  'LOG_DESCRIPTOR_STILL_OPEN=YES' \
  'NEXT_ACTION=CLASSIFY_LOG_IF_RECOVERED_OTHERWISE_ADD_BOUNDED_DIAGNOSTIC_LOGGING_AT_EXISTING_WORKFLOW_CATCH' \
  'VALIDATOR_WEAKENING_AUTHORIZED=NO' \
  'GENERATION_POLICY_CHANGE_AUTHORIZED=NO' \
  'FIX_AUTHORIZED=NO'

printf '\n=== WORKTREE ===\n'
git status --short
