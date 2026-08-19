#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=DELEGATION_WORKSPACE' \
  'ACTIVE_CORRIDOR=REQUEST_CHANGES_PERSISTENCE' \
  'CURRENT_CHECKPOINT=e0e26225' \
  'MODE=COLLABORATION' \
  'IMPLEMENTATION_AUTHORIZED=NO' \
  'PURPOSE=DEFINE_BOUNDED_REQUEST_CHANGES_ROUTE_AND_CLIENT_INTEGRATION_UNIT'

printf '\n=== CURRENT REQUEST CHANGES CLIENT SURFACE ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'Request Changes|requestChanges|request_changes|feedback' \
  client/src | head -240

printf '\n=== APPROVAL REQUEST CLIENT CONTRACT ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'approval_request_id|ApprovalRequest|approval request' \
  client/src | head -260

printf '\n=== APPROVAL REQUEST SERVER REGISTRATION ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'api-approval-request|approval-request|approval_request' \
  server routes | head -260

printf '\n=== EXISTING MUTATION ROUTE PATTERNS ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git \
  -E 'router\.post|router\.patch|router\.put' \
  routes | head -260

printf '\n=== TARGET WORKFLOW CONTRACT ===\n'
grep -n -A35 -B10 \
  'export interface RunMatildaConversationWorkflowInput' \
  server/matilda-chat-workflow.ts

printf '\n=== BOUNDED IMPLEMENTATION UNIT ===\n'
printf '%s\n' \
  'SERVER_ROUTE=REQUEST_CHANGES_THIN_ORCHESTRATION_ENDPOINT' \
  'SERVER_ROUTE_INPUT=APPROVAL_REQUEST_ID_AND_FEEDBACK' \
  'SERVER_IDENTITY_RESOLUTION=APPROVAL_REQUEST_TO_PROJECT_AND_ORIGINATING_CONVERSATION' \
  'SERVER_WORKFLOW_CALL=runMatildaConversationWorkflow' \
  'WORKFLOW_MESSAGE_SOURCE=EXECUTIVE_FEEDBACK' \
  'WORKFLOW_PROJECT_SOURCE=SERVER_RESOLVED_APPROVAL_REQUEST' \
  'WORKFLOW_CONVERSATION_SOURCE=SERVER_RESOLVED_APPROVAL_REQUEST' \
  'CLIENT_CHANGE=CONNECT_EXISTING_REQUEST_CHANGES_CONTROL_TO_NEW_ENDPOINT' \
  'CLIENT_MUST_NOT_SUPPLY_AUTHORITY_IDENTITIES=YES' \
  'SEPARATE_FEEDBACK_TABLE=NO' \
  'SEPARATE_INTERPRETATION_PATH=NO' \
  'APPROVAL_REQUEST_STATUS_MUTATION=NO' \
  'CANONICAL_PACKAGE_MUTATION=NO' \
  'DELEGATION_MUTATION=NO' \
  'EXECUTION_AUTHORITY=NO' \
  'ACTIVE_CONVERSATION_SWITCH=NO' \
  'NEW_SEMANTIC_AUTHORITY=NO' \
  'NEW_PERSISTENCE=NO'

printf '\n=== REQUIRED VALIDATION BOUNDARY ===\n'
printf '%s\n' \
  'UNKNOWN_APPROVAL_REQUEST=FAIL_CLOSED' \
  'EMPTY_FEEDBACK=REJECT' \
  'SERVER_RESOLVED_IDENTITIES=REQUIRED' \
  'ORIGINATING_CONVERSATION_NEW_TURN=REQUIRED' \
  'ACTIVE_CONVERSATION_UNCHANGED=REQUIRED' \
  'IEL_ENTRY_VIA_SHARED_WORKFLOW=REQUIRED' \
  'LIVING_DRAFT_UPDATE_VIA_EXISTING_WORKFLOW=REQUIRED' \
  'DOWNSTREAM_AUTHORITY_GRANTED=NO'

printf '\n=== READINESS ===\n'
echo 'CORRIDOR_1_IMPLEMENTATION_UNIT=DEFINED_BOUNDED'
echo 'IMPLEMENTATION_STARTED=NO'
echo 'NEXT_ACTION=REVIEW_IMPLEMENTATION_UNIT_BEFORE_AUTHORIZATION'

printf '\n=== WORKTREE ===\n'
git status --short
