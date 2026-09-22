#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="3ed3667a2"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

echo "============================================================"
echo " INVESTIGATION POINT 13 — APPROVALS PRESENTATION WIRING"
echo "============================================================"
echo "MODE=READ_ONLY_INSPECTION"
echo "PRODUCT_MUTATION=NO"
echo "AUTHORIZED_SCOPE=APPROVED_CANONICAL_PRESENTATION_IN_EXISTING_APPROVALS"

printf '\n=== A. CURRENT APPROVALS WORKSPACE IMPORTS / STATE ===\n'
sed -n '1,240p' client/src/approvals/ApprovalsWorkspace.tsx

printf '\n=== B. CURRENT APPROVALS WORKSPACE RENDER BODY ===\n'
sed -n '240,620p' client/src/approvals/ApprovalsWorkspace.tsx

printf '\n=== C. CURRENT APPROVAL REQUEST PROVIDER / HOOK ===\n'
sed -n '1,260p' client/src/approvals/ApprovalRequestProvider.tsx
sed -n '1,220p' client/src/approvals/useApprovalRequests.ts

printf '\n=== D. NEW CANONICAL READ CLIENT ===\n'
sed -n '1,220p' client/src/approvals/canonicalPackageReadApi.ts

printf '\n=== E. EXISTING APPROVALS TEST COVERAGE ===\n'
find client/src/approvals -maxdepth 2 -type f \
  \( -name '*test*' -o -name '*spec*' \) \
  -print \
  | sort

grep -RniE \
  'ApprovalsWorkspace|approval requests|Approve|Request Changes|Needs review|Executive Inbox' \
  client/src/approvals \
  --include='*.test.*' \
  --include='*.spec.*' \
  2>/dev/null || true

printf '\n=== F. CURRENT PROJECT-ID BINDING ===\n'
grep -RniE \
  'projectId|activeProject|selectedProject|useProject|project_id' \
  client/src/approvals/ApprovalsWorkspace.tsx \
  client/src/approvals/ApprovalRequestProvider.tsx \
  client/src/approvals/useApprovalRequests.ts \
  | head -160 || true

printf '\n=== G. CURRENT APPROVED/PENDING PRESENTATION TERMS ===\n'
grep -nE \
  'pending|Needs review|Approved|Canonical|selectedRequest|collection\.requests|requests\.map|DecisionBadge' \
  client/src/approvals/ApprovalsWorkspace.tsx \
  | head -220 || true

echo
echo "============================================================"
echo " INVESTIGATION POINT 13 — STOP HERE"
echo "============================================================"
echo "READ_ONLY_BRIDGE_IMPLEMENTED=YES"
echo "APPROVALS_PRESENTATION_WIRING_IMPLEMENTED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=DEFINE_EXACT_MINIMAL_APPROVALS_PRESENTATION_PATCH_FROM_CURRENT_STRUCTURE"
echo "CLEAR_STOPPING_POINT=YES"
