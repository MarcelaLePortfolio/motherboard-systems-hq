#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="$(git rev-parse --short=9 HEAD)"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

echo "===== ATLAS MINIMUM REACT PRESENTATION UNIT ====="
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "BASELINE=$BASELINE"

echo
echo "===== VERIFIED IDENTITY OWNERSHIP ====="
echo "PROJECT_ID_OWNER=MatildaConversationProvider.activeProjectId"
echo "CONVERSATION_ID_OWNER=MatildaConversationProvider.conversationId"
echo "CONTEXT_AVAILABLE_TO_SHELL=YES"
echo "NEW_IDENTITY_STORE_REQUIRED=NO"

echo
echo "===== VERIFIED MOUNT BOUNDARY ====="
echo "APP_TREE=ProjectContextProvider>MatildaConversationProvider>Shell"
echo "CONTEXT_CONSUMPTION_PATTERN=useMatildaConversation"
echo "EXISTING_SHELL_CONSUMER=NavigationRegion"
echo "MINIMUM_SAFE_HOST=Shell descendant under existing MatildaConversationProvider"

echo
echo "===== VERIFIED READ CONTRACT ====="
echo "METHOD=GET"
echo "ENDPOINT=/atlas/preexecution"
echo "REQUIRED_SCOPE=projectId+conversationId"
echo "MUTATION=NONE"
echo "CAUSAL_EXPLANATION=false"
echo "EXECUTION_HISTORY=false"
echo "APPROVAL_DECISION=false"
echo "AUTHORITY_DECISION=false"

echo
echo "===== MINIMUM IMPLEMENTATION CLASSIFICATION ====="
echo "CLIENT_API_HELPER=NEW_BOUNDED_READ_ONLY_HELPER"
echo "CLIENT_PRESENTATION=NEW_BOUNDED_REACT_COMPONENT"
echo "IDENTITY_SOURCE=EXISTING_USE_MATILDA_CONVERSATION_CONTEXT"
echo "SERVER_ROUTE_CHANGE=NO"
echo "MATILDA_PROVIDER_CHANGE=NO"
echo "MATILDA_RUNTIME_CHANGE=NO"
echo "CONVERSATION_LIFECYCLE_CHANGE=NO"
echo "EXECUTION_SEMANTICS_CHANGE=NO"
echo "LEGACY_DASHBOARD_RESTORATION=NO"
echo "NEW_GLOBAL_STATE=NO"
echo "NEW_CONVERSATION_ID_INFERENCE=NO"
echo "IMPLEMENTATION_SHAPE=READ_ONLY_ADDITIVE_PRESENTATION"

echo
echo "===== IMPLEMENTATION READINESS ====="
echo "Q1_EXACT_HOST_BOUNDARY=RESOLVED"
echo "Q2_CONVERSATION_ID_AVAILABLE=RESOLVED"
echo "Q3_MINIMUM_API_PATTERN=RESOLVED"
echo "Q4_PRESENTATION_ONLY_POSSIBLE=RESOLVED"
echo "CLASSIFICATION=IMPLEMENTATION_READY_PENDING_EXPLICIT_AUTHORIZATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "===== WORKTREE ====="
git status --short
