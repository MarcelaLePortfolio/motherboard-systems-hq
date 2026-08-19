#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=DELEGATION_WORKSPACE' \
  'ACTIVE_CORRIDOR=REQUEST_CHANGES_PERSISTENCE' \
  'CURRENT_CHECKPOINT=0ca8563b' \
  'MODE=COLLABORATION' \
  'IMPLEMENTATION_AUTHORIZED=NO' \
  'PURPOSE=REVIEW_BOUNDED_REQUEST_CHANGES_INTEGRATION_UNIT_AGAINST_ACTUAL_REPOSITORY_CONTRACTS'

printf '\n=== APPROVAL REQUEST READ MODEL ===\n'
sed -n '1,180p' client/src/approvals/approvalRequestApi.ts

printf '\n=== REQUEST CHANGES UI ===\n'
sed -n '200,405p' client/src/approvals/ApprovalsWorkspace.tsx

printf '\n=== APPROVAL REQUEST SERVER ROUTE ===\n'
sed -n '1,260p' routes/api-approval-request.ts

printf '\n=== APPROVAL REQUEST REPOSITORY ===\n'
sed -n '1,320p' db/approval-request-repository.ts

printf '\n=== APPROVAL REQUEST MODEL IDENTITY ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git \
  -E 'approval_request_id|project_id|conversation_id|package_id|package_version' \
  db/approval-request-* routes/api-approval-request* | head -320

printf '\n=== SHARED MATILDA WORKFLOW ENTRY CONTRACT ===\n'
sed -n '41,190p' server/matilda-chat-workflow.ts

printf '\n=== ACTIVE CONVERSATION MUTATION BOUNDARY ===\n'
sed -n '40,115p' routes/api-chat.ts

printf '\n=== REVIEW DETERMINATION ===\n'
printf '%s\n' \
  'PROPOSED_ROUTE_MODEL=THIN_ORCHESTRATION' \
  'PROPOSED_INPUT=APPROVAL_REQUEST_ID_AND_FEEDBACK' \
  'IDENTITY_AUTHORITY=SERVER_RESOLVED' \
  'INTERPRETATION_PATH=EXISTING_MATILDA_CONVERSATION_WORKFLOW' \
  'ACTIVE_CONVERSATION_MUTATION=PROHIBITED' \
  'APPROVAL_STATUS_MUTATION=PROHIBITED' \
  'CANONICAL_PACKAGE_MUTATION=PROHIBITED' \
  'DELEGATION_MUTATION=PROHIBITED' \
  'EXECUTION_AUTHORIZATION=PROHIBITED' \
  'PARALLEL_FEEDBACK_PERSISTENCE=PROHIBITED' \
  'NEW_SEMANTIC_AUTHORITY=NO' \
  'IMPLEMENTATION_STARTED=NO'

printf '\n=== REVIEW GATE ===\n'
echo 'NEXT_ACTION=CLASSIFY_IMPLEMENTATION_READINESS_FROM_INSPECTED_IDENTITY_RESOLUTION_PATH'
echo 'IMPLEMENTATION_AUTHORIZATION_REQUIRED_BEFORE_CODE_CHANGE=YES'

printf '\n=== WORKTREE ===\n'
git status --short
