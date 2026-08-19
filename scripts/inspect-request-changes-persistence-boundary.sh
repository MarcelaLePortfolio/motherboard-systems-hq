#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=DELEGATION_WORKSPACE' \
  'ACTIVE_CORRIDOR=REQUEST_CHANGES_PERSISTENCE' \
  'CURRENT_CHECKPOINT=6cbb70e9' \
  'MODE=COLLABORATION' \
  'IMPLEMENTATION_AUTHORIZED=NO' \
  'PURPOSE=INSPECT_REQUEST_CHANGES_PERSISTENCE_OWNERSHIP_AND_IMPLEMENTATION_BOUNDARY'

printf '\n=== GOVERNING REQUEST CHANGES ARCHITECTURE ===\n'
cat docs/architecture/EXECUTIVE_INBOX_REQUEST_CHANGES_ORCHESTRATION.md
printf '\n'
cat docs/architecture/EXECUTIVE_INBOX_INTENT_REVISION_CONTRACT.md

printf '\n=== EXECUTIVE CLIENT AUTHORITY BOUNDARY ===\n'
cat docs/architecture/EXECUTIVE_CLIENT_SERVER_AUTHORITY_BOUNDARY.md

printf '\n=== EXISTING CLIENT REQUEST CHANGES SURFACE ===\n'
grep -n -A95 -B25 -E \
  'Request Changes|feedback|handleFeedbackSubmit|feedbackReady' \
  client/src/approvals/ApprovalsWorkspace.tsx | head -360

printf '\n=== SERVER ROUTES RELATED TO REVISION OR MATILDA WORKFLOW ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude='*.bak' \
  -E 'request.?changes|revision|feedback|conversation workflow|shared Matilda|approval_request_id' \
  server routes db 2>/dev/null | head -360

printf '\n=== LIVING DRAFT AND CONVERSATION PERSISTENCE SURFACES ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude='*.bak' \
  -E 'matilda_living_draft_packages|conversation_id|lineage_id|draft_package_id|durableInterpretation' \
  db server routes 2>/dev/null | head -360

printf '\n=== APPROVAL REQUEST IDENTITY RESOLUTION ===\n'
sed -n '1,220p' db/approval-request-repository.ts
sed -n '1,220p' routes/api-approval-request.ts

printf '\n=== CORRIDOR 1 BOUNDARY QUESTIONS ===\n'
printf '%s\n' \
  'Q1=WHICH_SERVER_COMPONENT_MUST_OWN_APPROVAL_REQUEST_IDENTITY_RESOLUTION' \
  'Q2=WHERE_SHOULD_EXECUTIVE_FEEDBACK_BE_DURABLY_RECORDED' \
  'Q3=WHICH_EXISTING_MATILDA_WORKFLOW_MUST_RECEIVE_THE_FEEDBACK' \
  'Q4=HOW_IS_ORIGINATING_CONVERSATION_AND_LINEAGE_PRESERVED' \
  'Q5=HOW_DOES_REVISED_LIVING_DRAFT_RETURN_TO_EXECUTIVE_INBOX' \
  'Q6=WHAT_FAIL_CLOSED_VALIDATION_IS_REQUIRED_BEFORE_ANY_MUTATION'

printf '\n=== INVARIANTS ===\n'
printf '%s\n' \
  'CLIENT_SUBMITS=APPROVAL_REQUEST_ID_AND_FEEDBACK_ONLY' \
  'SERVER_RESOLVES=PROJECT_CONVERSATION_LINEAGE_AND_DRAFT_IDENTITIES' \
  'CLIENT_MUST_NOT_RESOLVE_RUNTIME_LINEAGE=YES' \
  'INTERPRETATION_REMAINS_SERVER_SIDE=YES' \
  'REQUEST_CHANGES_GRANTS_DELEGATION_AUTHORITY=NO' \
  'REQUEST_CHANGES_GRANTS_EXECUTION_AUTHORITY=NO' \
  'NEW_SEMANTIC_AUTHORITY=NO' \
  'IMPLEMENTATION_STARTED=NO'

printf '\n=== NEXT ACTION ===\n'
echo 'NEXT_ACTION=CLASSIFY_REQUEST_CHANGES_IMPLEMENTATION_READINESS_FROM_REPOSITORY_EVIDENCE'

printf '\n=== WORKTREE ===\n'
git status --short
