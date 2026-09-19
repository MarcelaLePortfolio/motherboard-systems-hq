#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="b5714628c"
PRE_HEAD="$(git rev-parse HEAD)"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== CURRENT APPROVAL API FUNCTION ===\n'
nl -ba client/src/approvals/approvalRequestApi.ts | sed -n '200,245p'

printf '\n=== CURRENT READ MODEL TYPE ===\n'
nl -ba client/src/approvals/approvalRequestApi.ts | sed -n '20,45p'

printf '\n=== CURRENT WORKSPACE APPROVE CALL ===\n'
nl -ba client/src/approvals/ApprovalsWorkspace.tsx | sed -n '188,202p'

printf '\n=== CURRENT SERVER ASSEMBLER BOUNDARY ===\n'
nl -ba db/approval-request-model-assembler.ts | sed -n '1,175p'

printf '\n=== VERIFY FAILED ATTEMPT LEFT PRODUCT FILES UNCHANGED ===\n'
git diff --exit-code -- \
  db/approval-request-model-assembler.ts \
  client/src/approvals/approvalRequestApi.ts \
  client/src/approvals/ApprovalsWorkspace.tsx \
  db/matilda-draft-revision-runtime.ts \
  db/matilda-canonical-package-runtime.ts \
  server/routes/matilda-canonical-package-route.ts

test "$(git rev-parse HEAD)" = "$PRE_HEAD"

printf '\n=== STOPPING POINT ===\n'
echo "IMPLEMENTATION_HYPOTHESIS_1=FAILED_ON_TEXT_ANCHOR_ONLY"
echo "PRODUCT_CODE_MUTATED=NO"
echo "DATABASE_MUTATED=NO"
echo "CANONICAL_BOUNDARY_CHANGED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "NEXT_ACTION=USE_EXACT_CURRENT_SOURCE_TO_BUILD_ONE_CORRECTED_NARROW_EDIT"
echo "CLEAR_STOPPING_POINT=YES"
