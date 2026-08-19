#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

LOG='/private/tmp/motherboard-matilda-503-diagnostic.log'
PROJECT_ID='hq'
CONVERSATION_ID='matilda-conversation-hq-1787159584712-q6x7o3'
MESSAGE='Create a simple internal status dashboard for tracking three workstreams: Product, Operations, and Marketing. Each workstream should show an owner, current status, next milestone, and blocker. Do not execute or delegate anything; help me define the request first.'

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=187fdef2' \
  'MODE=DIAGNOSTIC_ONLY' \
  'PRODUCTION_FIX_AUTHORIZED=NO' \
  'DIAGNOSTIC_LOGGING_COMMITTED=YES' \
  'TARGET=RESTART_BACKEND_WITH_FRESH_LOG_AND_CAPTURE_ROOT_EXCEPTION'

OLD_PID="$(lsof -tiTCP:3000 -sTCP:LISTEN | head -1 || true)"
if [[ -n "${OLD_PID:-}" ]]; then
  echo "OLD_BACKEND_PID=$OLD_PID"
  kill "$OLD_PID"
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    if ! kill -0 "$OLD_PID" 2>/dev/null; then
      break
    fi
    sleep 1
  done
fi

rm -f "$LOG"

nohup npm run dev > "$LOG" 2>&1 &
NEW_PID=$!
echo "NEW_BACKEND_PID=$NEW_PID"

BACKEND_READY=NO
for _ in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
  CODE="$(
    curl -sS -o /dev/null -w '%{http_code}' \
      'http://127.0.0.1:3000/api/chat/conversations?project_id=hq' \
      2>/dev/null || true
  )"
  if [[ "$CODE" == "200" ]]; then
    BACKEND_READY=YES
    break
  fi
  sleep 1
done

echo "BACKEND_READY=$BACKEND_READY"

if [[ "$BACKEND_READY" != "YES" ]]; then
  printf '\n=== STARTUP LOG ===\n'
  cat "$LOG" || true
  exit 1
fi

printf '\n=== REPRODUCE LIVE API CHAT REQUEST ===\n'
HTTP_CODE="$(
  curl -sS \
    --max-time 120 \
    -o /tmp/matilda-503-repro-response.json \
    -w '%{http_code}' \
    -X POST \
    http://127.0.0.1:3000/api/chat \
    -H 'Content-Type: application/json' \
    -d "$(node -e '
      const [project_id, conversation_id, message] = process.argv.slice(1);
      process.stdout.write(JSON.stringify({
        project_id,
        conversation_id,
        message,
        agent: "matilda"
      }));
    ' "$PROJECT_ID" "$CONVERSATION_ID" "$MESSAGE")"
)"

echo "HTTP_STATUS=$HTTP_CODE"

printf '\n=== API RESPONSE ===\n'
cat /tmp/matilda-503-repro-response.json || true
printf '\n'

printf '\n=== EXACT SERVER FAILURE ===\n'
grep -n -A45 -B20 -E \
  'Diagnostic failure details|Conversational response failed|Ollama returned|support reference|selected context|investigation lifecycle|malformed structured|durable interpretation|Error:' \
  "$LOG" || true

printf '\n=== SERVER LOG TAIL ===\n'
tail -180 "$LOG" || true

printf '\n=== POST-REQUEST PERSISTENCE CHECK ===\n'
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
WHERE project_id = '$PROJECT_ID'
  AND conversation_id = '$CONVERSATION_ID'
ORDER BY rowid DESC
LIMIT 3;
" || true

printf '\n=== CLASSIFICATION ===\n'
if [[ "$HTTP_CODE" == "503" ]]; then
  printf '%s\n' \
    'ISSUE_RESOLVED=NO' \
    'LIVE_503_REPRODUCED_AFTER_DIAGNOSTIC_RESTART=YES' \
    'ROOT_EXCEPTION_SHOULD_NOW_BE_VISIBLE_IN_LOG=YES' \
    'NEXT_ACTION=CLASSIFY_EXACT_ROOT_EXCEPTION_BEFORE_ANY_FIX'
elif [[ "$HTTP_CODE" =~ ^2 ]]; then
  printf '%s\n' \
    'ISSUE_RESOLVED_CANDIDATE=YES' \
    'LIVE_API_CHAT=PASS' \
    'NEXT_ACTION=VERIFY_SAME_REQUEST_FROM_DASHBOARD_BEFORE_DECLARING_RESOLVED'
else
  printf '%s\n' \
    'ISSUE_RESOLVED=NO' \
    "LIVE_HTTP_STATUS=$HTTP_CODE" \
    'NEXT_ACTION=CLASSIFY_OBSERVED_RUNTIME_RESULT'
fi

printf '%s\n' \
  'VALIDATOR_WEAKENING_AUTHORIZED=NO' \
  'GENERATION_POLICY_CHANGE_AUTHORIZED=NO' \
  'FIX_AUTHORIZED=NO'

printf '\n=== WORKTREE ===\n'
git status --short
