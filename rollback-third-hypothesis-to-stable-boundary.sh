#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
FAILED_HEAD="07dd01cdb"
STABLE_HEAD="0e8c4ff7a"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$FAILED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$FAILED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== THREE-HYPOTHESIS RULE TRIGGERED ===\n'
echo "HYPOTHESIS_1=FAILED"
echo "HYPOTHESIS_2=FAILED"
echo "HYPOTHESIS_3=FAILED"
echo "ACTION=REVERT_TO_LAST_KNOWN_STABLE_BOUNDARY"
echo "STABLE_HEAD=$STABLE_HEAD"

git revert --no-edit "$FAILED_HEAD"

printf '\n=== VERIFY REVERT ===\n'
test "$(git rev-parse --short=9 HEAD)" != "$FAILED_HEAD"
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  client/src/approvals/ApprovalsWorkspace.tsx \
  db/matilda-canonical-package-runtime.ts \
  server/routes/matilda-canonical-package-route.ts \
  db/matilda-draft-revision-runtime.ts \
  server/execution \
  server/operational \
  db/governance-execution-approvals.ts \
  db/governance-execution-scopes.ts \
  db/governance-execution-reconciliation-persistence.ts

printf '\n=== PRESERVE KNOWN PARTIAL STATE FOR REASSESSMENT ===\n'
grep -q 'draft_revision_id: string;' \
  client/src/approvals/approvalRequestApi.ts
grep -q 'draft_revision_id: normalizedDraftRevisionId' \
  client/src/approvals/approvalRequestApi.ts
grep -q 'createDraftRevisionForApprovalReview' \
  db/approval-request-model-assembler.ts
grep -q 'draft_revision_id: revision.draft_revision_id' \
  db/approval-request-model-assembler.ts

echo "REVERT_COMPLETE=YES"
echo "PRODUCT_FIX_COMPLETE=NO"
echo "RUNTIME_VALIDATION_READY=NO"
echo "NEXT_ACTION=REASSESS_WORKSPACE_CALLSITE_FROM_FRESH_BASE_WITH_DIFFERENT_APPROACH"
