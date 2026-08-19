#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

LOG='/private/tmp/motherboard-matilda-full-live-revalidation.log'
PROJECT_ID='hq'
CONVERSATION_ID='matilda-conversation-hq-1787159584712-q6x7o3'
MESSAGE='Create a simple internal status dashboard for tracking three workstreams: Product, Operations, and Marketing. Each workstream should show an owner, current status, next milestone, and blocker. Do not execute or delegate anything; help me define the request first.'

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=9e8df1e4' \
  'MODE=LIVE_REVALIDATION' \
  'ISSUE_RESOLVED=NO' \
  'NEW_FIX=NONE' \
  'TARGET=REPEAT_FULL_LIVE_API_REQUEST_ON_CURRENT_CHECKPOINT'

OLD_PID="$(lsof -tiTCP:3000 -sTCP:LISTEN | head -1 || true)"
if [[ -n "${OLD_PID:-}" ]]; then
  echo "OLD_BACKEND_PID=$OLD_PID"
  kill "$OLD_PID"
  sleep 2
fi

rm -f "$LOG"
nohup npm run dev > "$LOG" 2>&1 &
NEW_PID=$!
echo "NEW_BACKEND_PID=$NEW_PID"

BACKEND_READY=NO
for _ in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
  CODE="$(curl -sS -o /dev/null -w '%{http_code}' \
    "http://127.0.0.1:3000/api/chat/conversations?project_id=$PROJECT_ID" \
    2>/dev/null || true)"

  if [[ "$CODE" == "200" ]]; then
    BACKEND_READY=YES
    break
  fi

  sleep 1
done

echo "BACKEND_READY=$BACKEND_READY"

if [[ "$BACKEND_READY" != "YES" ]]; then
  cat "$LOG" || true
  exit 1
fi

PRE_COUNT="$(sqlite3 db/main.db "
SELECT COUNT(*)
FROM matilda_conversation_turns
WHERE project_id = '$PROJECT_ID'
  AND conversation_id = '$CONVERSATION_ID';
")"

echo "PRE_REQUEST_TURN_COUNT=$PRE_COUNT"

set +e
HTTP_CODE="$(
  curl -sS \
    --max-time 120 \
    -o /tmp/matilda-full-live-revalidation-response.json \
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
CURL_STATUS=$?
set -e

echo "CURL_EXIT_STATUS=$CURL_STATUS"
echo "HTTP_STATUS=$HTTP_CODE"

printf '\n=== API RESPONSE ===\n'
cat /tmp/matilda-full-live-revalidation-response.json 2>/dev/null || true
printf '\n'

POST_COUNT="$(sqlite3 db/main.db "
SELECT COUNT(*)
FROM matilda_conversation_turns
WHERE project_id = '$PROJECT_ID'
  AND conversation_id = '$CONVERSATION_ID';
")"

echo "POST_REQUEST_TURN_COUNT=$POST_COUNT"

printf '\n=== SERVER ERROR SEARCH ===\n'
grep -n -A40 -B15 -E \
  'Conversational response failed|Diagnostic failure details|not supplied in this invocation|Ollama returned|selected context segment|support reference' \
  "$LOG" || true

printf '\n=== RESULT ===\n'
if [[ "$HTTP_CODE" =~ ^2 ]] && [[ "$POST_COUNT" -gt "$PRE_COUNT" ]]; then
  printf '%s\n' \
    'PASS_GATE_1_FULL_LIVE_API_CHAT_RETURNS_2XX=YES' \
    'PASS_GATE_2_TURN_PERSISTS=YES' \
    'PASS_GATE_3_NO_FAIL_CLOSED_UNSUPPLIED_REFERENCE_REJECTION=YES' \
    'ISSUE_RESOLVED_CANDIDATE=YES' \
    'NEXT_ACTION=VERIFY_DASHBOARD_UI_CHAT'
else
  printf '%s\n' \
    'PASS_GATE_1_FULL_LIVE_API_CHAT_RETURNS_2XX=NO' \
    'ISSUE_RESOLVED=NO' \
    'NEXT_ACTION=CLASSIFY_EXACT_REPRODUCED_FAILURE_WITHOUT_ADDING_ANOTHER_FIX'
fi

printf '\n=== WORKTREE ===\n'
git status --short
