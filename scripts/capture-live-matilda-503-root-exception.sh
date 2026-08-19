#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=a11c290c' \
  'MODE=DIAGNOSTIC_ONLY' \
  'PRODUCTION_CHANGE=NONE' \
  'LIVE_BACKEND=http://127.0.0.1:3000' \
  'UI_503_REPRODUCED=YES' \
  'TARGET=CAPTURE_ORIGINAL_EXCEPTION_EMITTED_BY_RUNNING_SERVER'

PID="$(
  lsof -tiTCP:3000 -sTCP:LISTEN | head -1
)"

if [[ -z "${PID:-}" ]]; then
  echo 'BACKEND_PID=NOT_FOUND'
  exit 1
fi

echo "BACKEND_PID=$PID"

printf '\n=== PROCESS COMMAND ===\n'
ps -p "$PID" -o pid=,ppid=,command=

printf '\n=== PROCESS OPEN FILES / OUTPUT TARGETS ===\n'
lsof -p "$PID" 2>/dev/null | \
  grep -E '(^COMMAND|stdout|stderr|\.log|/dev/ttys|pts/|server/index|motherboard-systems)' || true

printf '\n=== PARENT PROCESS CHAIN ===\n'
CURRENT="$PID"
for _ in 1 2 3 4; do
  [[ -n "$CURRENT" ]] || break
  ps -p "$CURRENT" -o pid=,ppid=,command= || true
  CURRENT="$(
    ps -p "$CURRENT" -o ppid= 2>/dev/null | tr -d ' '
  )"
done

printf '\n=== SERVER LOG CANDIDATES ===\n'
find . /tmp \
  -path './node_modules' -prune -o \
  -path './.git' -prune -o \
  -type f \
  \( -name '*.log' -o -name '*server*out*' -o -name '*server*err*' -o -name '*npm*log*' \) \
  -mmin -240 -print 2>/dev/null | head -160

printf '\n=== RECENT MATILDA ERROR LINES ===\n'
while IFS= read -r file; do
  grep -Hni -E \
    'Matilda conversation workflow|Conversational response failed|Ollama returned|503|support reference|selected context|investigation lifecycle|malformed structured|durable interpretation' \
    "$file" 2>/dev/null || true
done < <(
  find . /tmp \
    -path './node_modules' -prune -o \
    -path './.git' -prune -o \
    -type f \
    \( -name '*.log' -o -name '*server*out*' -o -name '*server*err*' -o -name '*npm*log*' \) \
    -mmin -240 -print 2>/dev/null
)

printf '\n=== SOURCE THROW / FAIL-CLOSED SITES ===\n'
grep -nE \
  'throw new Error|Conversational response failed|MatildaConversationWorkflowUnavailableError' \
  server/matilda-chat-workflow.ts scripts/utils/ollamaChat.ts | \
  tail -220

printf '\n=== VERIFIED REPOSITORY CHECKPOINT ===\n'
git show --stat --oneline --decorate a11c290c
git status --short

printf '\n=== CLASSIFICATION ===\n'
printf '%s\n' \
  'LIVE_503_CONFIRMED=YES' \
  'OLLAMA_SERVICE_FAILURE=NO' \
  'MODEL_MISSING=NO' \
  'ROOT_EXCEPTION=NOT_YET_VISIBLE_IN_HTTP_RESPONSE' \
  'NEXT_ACTION=USE_RUNNING_SERVER_STDERR_OR_EXACT_LOGGED_EXCEPTION_TO_CLASSIFY' \
  'VALIDATOR_WEAKENING_AUTHORIZED=NO' \
  'GENERATION_POLICY_CHANGE_AUTHORIZED=NO' \
  'FIX_AUTHORIZED=NO'
