#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=50cf7781' \
  'ISSUE_RESOLVED=NO' \
  'DIRECT_LIVE_API_PREVIOUSLY_PASSED=YES' \
  'DASHBOARD_PROXY_HTTP_STATUS=503' \
  'TURN_PERSISTED=NO' \
  'FIX_AUTHORIZED=NO' \
  'TARGET=CLASSIFY_EXACT_BACKEND_EXCEPTION_FROM_PROXY_503'

PID="$(lsof -tiTCP:3000 -sTCP:LISTEN | head -1 || true)"

if [[ -z "${PID:-}" ]]; then
  echo 'BACKEND_PID=NOT_FOUND'
  exit 1
fi

echo "BACKEND_PID=$PID"

printf '\n=== BACKEND PROCESS ===\n'
ps -p "$PID" -o pid=,ppid=,etime=,command= || true

printf '\n=== BACKEND STDOUT STDERR TARGETS ===\n'
lsof -a -p "$PID" -d 1,2 -Fn 2>/dev/null || true

LOG_PATH="$(
  lsof -a -p "$PID" -d 1 -Fn 2>/dev/null |
  sed -n 's/^n//p' |
  head -1
)"

echo "LOG_PATH=${LOG_PATH:-UNRESOLVED}"

printf '\n=== CURRENT BACKEND LOG ===\n'
if [[ -n "${LOG_PATH:-}" && -e "$LOG_PATH" ]]; then
  tail -220 "$LOG_PATH" || true

  printf '\n=== EXACT MATILDA FAILURE CONTEXT ===\n'
  grep -n -A50 -B20 -E \
    'Conversational response failed|Diagnostic failure details|not supplied in this invocation|Ollama returned|selected context segment|conversation support reference|project-context support reference|investigation lifecycle|malformed structured response' \
    "$LOG_PATH" || true
else
  echo 'LOG_PATH_READABLE=NO'
fi

printf '\n=== CURRENT PERSISTENCE STATE ===\n'
sqlite3 -header -column db/main.db "
SELECT
  turn_id,
  project_id,
  conversation_id,
  user_message,
  assistant_reply,
  interpretation_entry_id,
  created_at
FROM matilda_conversation_turns
WHERE project_id = 'hq'
  AND conversation_id = 'matilda-conversation-hq-1787159584712-q6x7o3'
ORDER BY rowid DESC
LIMIT 3;
" || true

printf '\n=== CLASSIFICATION ===\n'
printf '%s\n' \
  'PROXY_TRANSPORT_FAILURE_ESTABLISHED=NO' \
  'BACKEND_503_REACHED_THROUGH_PROXY=YES' \
  'VALIDATOR_WEAKENING_AUTHORIZED=NO' \
  'GENERATION_POLICY_CHANGE_AUTHORIZED=NO' \
  'SECOND_OR_THIRD_FIX_AUTHORIZED=NO' \
  'NEXT_ACTION=CLASSIFY_EXACT_LOGGED_BACKEND_REJECTION_BEFORE_ANY_FIX'

printf '\n=== WORKTREE ===\n'
git status --short
