#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="08be68a6c"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== CURRENT CLASSIFICATION ===\n'
echo "TARGETED_APPROVAL_TESTS=PASS"
echo "SERVER_BUILD=PASS"
echo "CLIENT_BUILD=FAIL"
echo "CLIENT_BUILD_FAILURE=UNUSED_FEEDBACKREADY_STATE"
echo "DRAFT_REVISION_TEST_REPAIR_FAILURE=NO"
echo "APPROVAL_HANDOFF_FAILURE=NO"
echo "PRODUCT_FIX_COMPLETE=NO"
echo "RUNTIME_VALIDATION_READY=NO"
echo "MODE=READ_ONLY_INSPECTION"

printf '\n=== FEEDBACKREADY DECLARATION AND ALL REFERENCES ===\n'
grep -n -C 4 -E \
  'feedbackReady|setFeedbackReady' \
  client/src/approvals/ApprovalsWorkspace.tsx || true

printf '\n=== SURROUNDING APPROVAL WORKSPACE STATE ===\n'
nl -ba client/src/approvals/ApprovalsWorkspace.tsx | sed -n '135,180p'

printf '\n=== FEEDBACK STATE TRANSITION CONTEXT ===\n'
nl -ba client/src/approvals/ApprovalsWorkspace.tsx | sed -n '200,425p'

printf '\n=== GIT HISTORY FOR FEEDBACKREADY LINES ===\n'
git blame -L 140,175 -- client/src/approvals/ApprovalsWorkspace.tsx || true
git log --oneline --decorate -n 20 -- client/src/approvals/ApprovalsWorkspace.tsx

printf '\n=== VERIFY DRAFT REVISION REPAIR REMAINS VALIDATED ===\n'
npx tsx --test \
  db/approval-request-model-assembler.test.ts \
  routes/api-approval-request.test.ts

printf '\n=== VERIFY SERVER BUILD STILL PASSES ===\n'
npm run build

printf '\n=== VERIFY PROTECTED APPROVAL BOUNDARIES UNCHANGED ===\n'
git diff --exit-code -- \
  db/approval-request-model-assembler.ts \
  client/src/approvals/approvalRequestApi.ts \
  client/src/approvals/ApprovalsWorkspace.tsx \
  db/matilda-draft-revision-runtime.ts \
  db/matilda-canonical-package-runtime.ts \
  server/routes/matilda-canonical-package-route.ts \
  server/execution \
  server/operational \
  db/governance-execution-approvals.ts \
  db/governance-execution-scopes.ts \
  db/governance-execution-reconciliation-persistence.ts

printf '\n=== STOPPING POINT ===\n'
echo "INSPECTION_COMPLETE=YES"
echo "MUTATION_EXECUTED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=CLASSIFY_FEEDBACKREADY_AS_PREEXISTING_CLIENT_BUILD_DEBT_OR_APPROVAL_FIX_REGRESSION"
echo "CLEAR_STOPPING_POINT=YES"
