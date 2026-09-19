#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="3be2f52dc"
PRE_HEAD="$(git rev-parse HEAD)"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== CURRENT WORKSPACE APPROVE CALL ===\n'
nl -ba client/src/approvals/ApprovalsWorkspace.tsx | sed -n '186,206p'

printf '\n=== ALL approveCanonicalPackage CALL SITES ===\n'
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  --exclude-dir=.git \
  'approveCanonicalPackage' \
  client/src 2>/dev/null || true

printf '\n=== CURRENT CLIENT API CONTRACT ===\n'
nl -ba client/src/approvals/approvalRequestApi.ts | sed -n '20,40p'
nl -ba client/src/approvals/approvalRequestApi.ts | sed -n '205,245p'

printf '\n=== CURRENT SERVER ASSEMBLER CONTRACT ===\n'
grep -n -B4 -A8 \
  -E 'createDraftRevisionForApprovalReview|draft_revision_id' \
  db/approval-request-model-assembler.ts

printf '\n=== VERIFY PARTIAL IMPLEMENTATION STATE ===\n'
grep -q 'draft_revision_id: string;' \
  client/src/approvals/approvalRequestApi.ts
grep -q 'draft_revision_id: normalizedDraftRevisionId' \
  client/src/approvals/approvalRequestApi.ts
grep -q 'createDraftRevisionForApprovalReview' \
  db/approval-request-model-assembler.ts
grep -q 'draft_revision_id: revision.draft_revision_id' \
  db/approval-request-model-assembler.ts

printf '\n=== VERIFY PROTECTED BOUNDARIES UNCHANGED ===\n'
git diff --exit-code -- \
  db/matilda-canonical-package-runtime.ts \
  server/routes/matilda-canonical-package-route.ts \
  db/matilda-draft-revision-runtime.ts \
  server/execution \
  server/operational \
  db/governance-execution-approvals.ts \
  db/governance-execution-scopes.ts \
  db/governance-execution-reconciliation-persistence.ts

test "$(git rev-parse HEAD)" = "$PRE_HEAD"

printf '\n=== STOPPING POINT ===\n'
echo "IMPLEMENTATION_HYPOTHESIS_2=FAILED_ON_WORKSPACE_TEXT_ANCHOR_ONLY"
echo "SERVER_ASSEMBLER_PARTIAL_IMPLEMENTATION=PRESENT"
echo "CLIENT_API_PARTIAL_IMPLEMENTATION=PRESENT"
echo "WORKSPACE_HANDOFF_COMPLETION=NOT_YET_PROVEN"
echo "TARGETED_TESTS_RUN=NO"
echo "SERVER_BUILD_RUN=NO"
echo "CLIENT_BUILD_RUN=NO"
echo "RUNTIME_VALIDATION_READY=NO"
echo "NEXT_ACTION=USE_EXACT_WORKSPACE_CALLSITE_FOR_THIRD_AND_FINAL_HYPOTHESIS"
echo "CLEAR_STOPPING_POINT=YES"
