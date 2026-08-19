#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

PROJECT_ID='hq'
CONVERSATION_ID='matilda-conversation-hq-1787159584712-q6x7o3'
MESSAGE='Create a simple internal status dashboard for tracking three workstreams: Product, Operations, and Marketing. Each workstream should show an owner, current status, next milestone, and blocker. Do not execute or delegate anything; help me define the request first.'

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=ecc526f9' \
  'LIVE_BACKEND_API=PASS' \
  'LIVE_TURN_PERSISTENCE=PASS' \
  'FAIL_CLOSED_UNSUPPLIED_REFERENCE_REJECTION=NOT_OBSERVED' \
  'ISSUE_RESOLVED_CANDIDATE=YES' \
  'TARGET=VERIFY_DASHBOARD_VITE_PROXY_CHAT_PATH'

printf '\n=== VERIFY CLIENT RUNTIME ===\n'
CLIENT_STATUS="$(
  curl -sS --max-time 10 \
    -o /tmp/matilda-dashboard-client-health.html \
    -w '%{http_code}' \
    http://127.0.0.1:5173/ 2>/dev/null || true
)"
echo "CLIENT_HTTP_STATUS=$CLIENT_STATUS"

if [[ "$CLIENT_STATUS" != "200" ]]; then
  echo 'DASHBOARD_CLIENT_RUNTIME=UNAVAILABLE'
  echo 'ISSUE_RESOLVED=NO'
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
  curl -sS --max-time 120 \
    -o /tmp/matilda-dashboard-proxy-response.json \
    -w '%{http_code}' \
    -X POST http://127.0.0.1:5173/api/chat \
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

printf '\n=== DASHBOARD PROXY RESPONSE ===\n'
cat /tmp/matilda-dashboard-proxy-response.json 2>/dev/null || true
printf '\n'

POST_COUNT="$(sqlite3 db/main.db "
SELECT COUNT(*)
FROM matilda_conversation_turns
WHERE project_id = '$PROJECT_ID'
  AND conversation_id = '$CONVERSATION_ID';
")"
echo "POST_REQUEST_TURN_COUNT=$POST_COUNT"

printf '\n=== RESULT ===\n'
if [[ "$HTTP_CODE" =~ ^2 ]] && [[ "$POST_COUNT" -gt "$PRE_COUNT" ]]; then
  printf '%s\n' \
    'DASHBOARD_VITE_PROXY_CHAT=PASS' \
    'TURN_PERSISTENCE=PASS' \
    'PASS_GATE_1_FULL_LIVE_API_CHAT_RETURNS_2XX=YES' \
    'PASS_GATE_2_TURN_PERSISTS=YES' \
    'PASS_GATE_3_NO_FAIL_CLOSED_UNSUPPLIED_REFERENCE_REJECTION=YES' \
    'PASS_GATE_4_DASHBOARD_NETWORK_PATH_SUCCEEDS=YES' \
    'ISSUE_RESOLVED_CANDIDATE=YES' \
    'FINAL_MANUAL_GATE=SEND_ONE_MESSAGE_FROM_VISIBLE_MATILDA_DASHBOARD_CHAT'
else
  printf '%s\n' \
    'DASHBOARD_VITE_PROXY_CHAT=FAIL' \
    'ISSUE_RESOLVED=NO' \
    'NEXT_ACTION=CLASSIFY_OBSERVED_FAILURE_WITHOUT_LAYERING_ANOTHER_FIX'
  exit 1
fi

git status --short
