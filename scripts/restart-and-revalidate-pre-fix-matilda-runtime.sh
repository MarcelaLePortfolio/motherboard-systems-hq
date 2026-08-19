#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

LOG='/private/tmp/motherboard-matilda-pre-fix-revalidation.log'
PROJECT_ID='hq'
CONVERSATION_ID='matilda-conversation-hq-1787159584712-q6x7o3'
MESSAGE='Create a simple internal status dashboard for tracking three workstreams: Product, Operations, and Marketing. Each workstream should show an owner, current status, next milestone, and blocker. Do not execute or delegate anything; help me define the request first.'

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=1c6780fe' \
  'ISSUE_RESOLVED=NO' \
  'RUNTIME_BASELINE=09342faa_OLLAMACHAT' \
  'PROMPT_FIX_REVERTED=YES' \
  'TARGET=RESTART_BACKEND_AND_REVALIDATE_PRE_FIX_RUNTIME'

OLD_PID="$(lsof -tiTCP:3000 -sTCP:LISTEN | head -1 || true)"
if [[ -n "${OLD_PID:-}" ]]; then
  echo "OLD_BACKEND_PID=$OLD_PID"
  kill "$OLD_PID"
  sleep 2
fi

rm -f "$LOG"
nohup npm run dev > "$LOG" 2>&1 &
echo "NEW_BACKEND_WRAPPER_PID=$!"

BACKEND_READY=NO
for _ in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
  CODE="$(curl -sS -o /dev/null -w '%{http_code}' \
    "http://localhost:3000/api/chat/conversations?project_id=$PROJECT_ID" \
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
    -o /tmp/matilda-pre-fix-revalidation-response.json \
    -w '%{http_code}' \
    -X POST \
    http://localhost:3000/api/chat \
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
cat /tmp/matilda-pre-fix-revalidation-response.json 2>/dev/null || true
printf '\n'

POST_COUNT="$(sqlite3 db/main.db "
SELECT COUNT(*)
FROM matilda_conversation_turns
WHERE project_id = '$PROJECT_ID'
  AND conversation_id = '$CONVERSATION_ID';
")"
echo "POST_REQUEST_TURN_COUNT=$POST_COUNT"

printf '\n=== SERVER FAILURE SEARCH ===\n'
grep -n -A45 -B20 -E \
  'Conversational response failed|Diagnostic failure details|timed out|not supplied in this invocation|Ollama returned|selected context segment|support reference' \
  "$LOG" || true

printf '\n=== RESULT ===\n'
if [[ "$HTTP_CODE" =~ ^2 ]] && [[ "$POST_COUNT" -gt "$PRE_COUNT" ]]; then
  printf '%s\n' \
    'PRE_FIX_RUNTIME_REVALIDATION=PASS' \
    'TURN_PERSISTENCE=PASS' \
    'ISSUE_RESOLVED=NO' \
    'NEXT_ACTION=REVALIDATE_DASHBOARD_PROXY_VIA_LOCALHOST_5173'
else
  printf '%s\n' \
    'PRE_FIX_RUNTIME_REVALIDATION=FAIL' \
    'ISSUE_RESOLVED=NO' \
    'NEXT_ACTION=CLASSIFY_FAILURE_AS_PRE_EXISTING_GENERATION_INSTABILITY_AND_SELECT_DIFFERENT_SOLUTION_CLASS'
fi

printf '\n=== WORKTREE ===\n'
git status --short
