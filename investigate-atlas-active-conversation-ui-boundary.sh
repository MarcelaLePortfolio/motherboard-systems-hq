#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="2444e54fd"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

echo "===== ATLAS ACTIVE CONVERSATION UI BOUNDARY ====="
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "BASELINE=$BASELINE"

echo
echo "===== CONVERSATION RUNTIME DEFINITIONS ====="
grep -RniE -B35 -A120 \
  'getOrCreateActiveMatildaConversation|setActiveMatildaConversation|createMatildaConversation|active.*conversation|conversation.*active' \
  db server \
  --include='*.ts' \
  --include='*.js' \
  2>/dev/null | head -n 3500 || true

echo
echo "===== HTTP CONVERSATION IDENTITY TRANSPORT ====="
grep -RniE -B35 -A120 \
  'conversation_id|conversationId|activeConversation|active_conversation' \
  server/routes server/index.ts \
  --include='*.ts' \
  --include='*.js' \
  2>/dev/null | head -n 3500 || true

echo
echo "===== UI CONVERSATION IDENTITY TRANSPORT ====="
grep -RniE -B40 -A140 \
  'conversation_id|conversationId|activeConversation|currentConversation|/conversation|/chat|matilda' \
  public \
  --include='*.js' \
  --include='*.html' \
  --include='*.ts' \
  2>/dev/null | head -n 4500 || true

echo
echo "===== CLASSIFICATION TARGET ====="
echo "QUESTION_1=DOES_EXISTING_HTTP_TRANSPORT_EXPOSE_ACTIVE_CONVERSATION_ID"
echo "QUESTION_2=DOES_UI_ALREADY_RETAIN_CONVERSATION_ID"
echo "QUESTION_3=IS_CONVERSATION_ID_RETURNED_BY_EXISTING_MATILDA_CHAT_FLOW"
echo "QUESTION_4=CAN_PREEXECUTION_PRESENTATION_REUSE_EXISTING_IDENTITY"
echo "NO_NEW_CONVERSATION_ID_INFERENCE=YES"
echo "NO_HARDCODED_CONVERSATION_ID=YES"
echo "NO_UI_IMPLEMENTATION=YES"
echo "NO_ROUTE_IMPLEMENTATION=YES"
echo "NO_RUNTIME_CHANGE=YES"
echo "DOGFOOD_CLEANUP=FROZEN"

echo
echo "===== WORKTREE ====="
git status --short
