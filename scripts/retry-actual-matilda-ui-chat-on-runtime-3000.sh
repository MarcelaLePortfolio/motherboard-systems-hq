#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=27409aa0' \
  'MODE=DIAGNOSTIC_ONLY' \
  'PRODUCTION_CHANGE=NONE' \
  'DASHBOARD_BACKEND_RUNTIME=http://127.0.0.1:3000' \
  'CLIENT_RUNTIME=http://127.0.0.1:5173' \
  'VITE_PROXY_TARGET=http://localhost:3000' \
  'TARGET=REPLAY_ACTUAL_API_CHAT_REQUEST_AGAINST_IDENTIFIED_BACKEND'

PROJECT_ID='hq'
CONVERSATION_ID='matilda-conversation-hq-1787159584712-q6x7o3'
MESSAGE='Create a simple internal status dashboard for tracking three workstreams: Product, Operations, and Marketing. Each workstream should show an owner, current status, next milestone, and blocker. Do not execute or delegate anything; help me define the request first.'

printf '\n=== BACKEND HEALTH ===\n'
curl -sS --max-time 10 \
  -o /tmp/matilda-backend-health.txt \
  -w 'HTTP_STATUS=%{http_code}\n' \
  http://127.0.0.1:3000/api/chat/conversations?project_id=hq || true
cat /tmp/matilda-backend-health.txt 2>/dev/null || true
printf '\n'

printf '\n=== ACTUAL API CHAT REQUEST ===\n'
set +e
HTTP_CODE="$(
  curl -sS \
    --max-time 120 \
    -o /tmp/matilda-ui-chat-response.json \
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
cat /tmp/matilda-ui-chat-response.json 2>/dev/null || true
printf '\n'

printf '\n=== POST-REQUEST TURN CHECK ===\n'
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
LIMIT 5;
" || true

printf '\n=== CLASSIFICATION ===\n'
if [[ "$HTTP_CODE" == "503" ]]; then
  printf '%s\n' \
    'UI_503_REPRODUCED=YES' \
    'FAILURE_SURFACE=LIVE_BACKEND_API_CHAT' \
    'RUNTIME_OWNER=server/index.ts_PORT_3000' \
    'NEXT_ACTION=CAPTURE_UNDERLYING_WORKFLOW_EXCEPTION_FROM_RUNNING_SERVER'
elif [[ "$HTTP_CODE" =~ ^2 ]]; then
  printf '%s\n' \
    'UI_503_REPRODUCED=NO' \
    'LIVE_BACKEND_API_CHAT=PASS_ON_RETRY' \
    'RUNTIME_OWNER=server/index.ts_PORT_3000' \
    'NEXT_ACTION=RETRY_SAME_REQUEST_FROM_DASHBOARD_AND_COMPARE'
else
  printf '%s\n' \
    'UI_503_REPRODUCED=NO' \
    "LIVE_BACKEND_HTTP_STATUS=$HTTP_CODE" \
    'RUNTIME_OWNER=server/index.ts_PORT_3000' \
    'NEXT_ACTION=CLASSIFY_OBSERVED_LIVE_BACKEND_FAILURE'
fi

printf '%s\n' \
  'VALIDATOR_WEAKENING_AUTHORIZED=NO' \
  'GENERATION_POLICY_CHANGE_AUTHORIZED=NO' \
  'FIX_AUTHORIZED=NO'

printf '\n=== WORKTREE ===\n'
git status --short
