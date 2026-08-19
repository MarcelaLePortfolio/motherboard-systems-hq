#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=8171850b' \
  'MODE=DIAGNOSTIC_ONLY' \
  'PRODUCTION_CHANGE=NONE' \
  'OLLAMA_SERVICE=HEALTHY' \
  'DIRECT_MODEL_GENERATION=PASS' \
  'GENERIC_RUNTIME_REJECTION_REPRODUCED=NO' \
  'TARGET=REPRODUCE_ACTUAL_DASHBOARD_CHAT_REQUEST_AND_CAPTURE_SERVER_FAILURE'

PROJECT_ID='hq'
CONVERSATION_ID='matilda-conversation-hq-1787159584712-q6x7o3'
MESSAGE='Create a simple internal status dashboard for tracking three workstreams: Product, Operations, and Marketing. Each workstream should show an owner, current status, next milestone, and blocker. Do not execute or delegate anything; help me define the request first.'

printf '\n=== ACTUAL ACTIVE UI CONTEXT ===\n'
printf 'PROJECT_ID=%s\n' "$PROJECT_ID"
printf 'CONVERSATION_ID=%s\n' "$CONVERSATION_ID"
printf 'MESSAGE=%s\n' "$MESSAGE"

printf '\n=== CHAT ROUTE REQUEST CONTRACT ===\n'
sed -n '164,245p' routes/api-chat.ts

printf '\n=== WORKFLOW OLLAMA CALL CONTEXT ===\n'
sed -n '99,240p' server/matilda-chat-workflow.ts

printf '\n=== LIVE API CHAT REQUEST ===\n'
set +e
HTTP_CODE="$(
  curl -sS \
    --max-time 120 \
    -o /tmp/matilda-ui-chat-response.json \
    -w '%{http_code}' \
    -X POST \
    http://127.0.0.1:8080/api/chat \
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

printf '\n=== POST-REQUEST IEL CHECK ===\n'
sqlite3 -header -column db/main.db "
SELECT *
FROM matilda_interpretation_evidence_ledger
WHERE project_id = '$PROJECT_ID'
  AND conversation_id = '$CONVERSATION_ID'
ORDER BY rowid DESC
LIMIT 5;
" 2>/dev/null || true

printf '\n=== CLASSIFICATION ===\n'
if [[ "$HTTP_CODE" == "503" ]]; then
  printf '%s\n' \
    'UI_503_REPRODUCED=YES' \
    'FAILURE_SURFACE=ACTUAL_API_CHAT_WORKFLOW' \
    'NEXT_ACTION=CAPTURE_UNDERLYING_WORKFLOW_EXCEPTION_BEFORE_503_TRANSLATION'
elif [[ "$HTTP_CODE" =~ ^2 ]]; then
  printf '%s\n' \
    'UI_503_REPRODUCED=NO' \
    'ACTUAL_API_CHAT_WORKFLOW=PASS_ON_RETRY' \
    'NEXT_ACTION=COMPARE_ORIGINAL_UI_REQUEST_CONTEXT_WITH_SUCCESSFUL_REQUEST'
else
  printf '%s\n' \
    'UI_503_REPRODUCED=NO' \
    "ACTUAL_HTTP_STATUS=$HTTP_CODE" \
    'NEXT_ACTION=CLASSIFY_OBSERVED_API_FAILURE'
fi

printf '%s\n' \
  'VALIDATOR_WEAKENING_AUTHORIZED=NO' \
  'GENERATION_POLICY_CHANGE_AUTHORIZED=NO' \
  'FIX_AUTHORIZED=NO'

printf '\n=== WORKTREE ===\n'
git status --short
