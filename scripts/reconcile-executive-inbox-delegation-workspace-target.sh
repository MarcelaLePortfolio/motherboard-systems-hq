#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=DELEGATION_WORKSPACE' \
  'MODE=COLLABORATION' \
  'IMPLEMENTATION_AUTHORIZED=NO' \
  'CURRENT_CHECKPOINT=08872d0b' \
  'PURPOSE=RECONCILE_EXISTING_EXECUTIVE_INBOX_WITH_DELEGATION_WORKSPACE_TARGET'

printf '\n=== CURRENT APPROVAL REQUEST MODEL ===\n'
sed -n '1,230p' db/approval-request-model-assembler.ts

printf '\n=== CURRENT APPROVAL REQUEST REPOSITORY ===\n'
sed -n '1,180p' db/approval-request-repository.ts

printf '\n=== CURRENT EXECUTIVE DECISION CONTROLS ===\n'
grep -n -A35 -B20 -E \
  'Approve|Request Changes|Delegate|Execute|available_decisions' \
  client/src/approvals/ApprovalsWorkspace.tsx | head -320

printf '\n=== CLIENT DECISION TYPES ===\n'
sed -n '1,155p' client/src/approvals/approvalRequestApi.ts

printf '\n=== CANONICAL PACKAGE APPROVAL ROUTE ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git \
  -E 'canonical-package|approval_actor' \
  server routes client/src/approvals 2>/dev/null | head -240

printf '\n=== REQUEST CHANGES IMPLEMENTATION EVIDENCE ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude='*.bak' \
  -E 'request.?changes|revision feedback|approval_request_id.*feedback' \
  server routes db client/src 2>/dev/null | head -280

printf '\n=== DELEGATION MUTATION EVIDENCE ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude='*.bak' \
  -E 'createDelegation|insert.*governance_delegations|INSERT INTO governance_delegations|authorize.*delegation|delegat(e|ion).*route' \
  server routes db client/src 2>/dev/null | head -280

printf '\n=== OPERATIONAL INTAKE RELATIONSHIP ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git \
  -E 'operational.intake|governance_delegations' \
  db/operational-intake-runtime.ts server routes 2>/dev/null | head -220

printf '\n=== RECONCILIATION QUESTIONS ===\n'
printf '%s\n' \
  'Q1=WHICH_EXECUTIVE_DECISIONS_ARE_CURRENTLY_PROJECTED_BY_APPROVAL_REQUEST_READ_MODEL' \
  'Q2=WHICH_DECISIONS_HAVE_AUTHORITATIVE_MUTATION_ROUTES' \
  'Q3=IS_REQUEST_CHANGES_IMPLEMENTED_OR_PRESENTATION_ONLY' \
  'Q4=IS_EXPLICIT_DELEGATION_AUTHORIZATION_IMPLEMENTED_OR_MISSING' \
  'Q5=WHAT_HANDOFF_TO_MISSION_CONTROL_ALREADY_EXISTS_AFTER_DELEGATION' \
  'Q6=WHICH_PROVISIONAL_CORRIDORS_ARE_ACTUAL_GAPS_VERSUS_ALREADY_COMPLETE_CAPABILITY'

printf '\n=== CORRIDOR MAP STATUS ===\n'
echo 'CORRIDOR_MAP=PROVISIONAL'
echo 'NEXT_DECISION=FINALIZE_CORRIDOR_MAP_FROM_RECONCILIATION_EVIDENCE'
echo 'IMPLEMENTATION_STARTED=NO'

printf '\n=== WORKTREE ===\n'
git status --short
