#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="75b276d0d"
DR_BOUNDARY="20260918_153528"
PRE_HEAD="$(git rev-parse HEAD)"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== BASELINE ===\n'
echo "MODE=READ_ONLY"
echo "PROVEN_FAILURE=draft_revision_id_is_required"
echo "REVISION_CREATOR_EXISTS=YES"
echo "REVISION_CREATOR_CALL_SITES=0"
echo "CURRENT_DRAFT_REVISION_COUNT=0"
echo "DR_RECOVERY_BOUNDARY=$DR_BOUNDARY"

printf '\n=== APPROVAL READ MODEL ASSEMBLER ===\n'
nl -ba db/approval-request-model-assembler.ts | sed -n '1,240p'

printf '\n=== APPROVAL REQUEST ROUTE ===\n'
if [ -f routes/api-approval-request.ts ]; then
  nl -ba routes/api-approval-request.ts | sed -n '1,300p'
fi

if [ -f server/routes/api-approval-request.ts ]; then
  nl -ba server/routes/api-approval-request.ts | sed -n '1,300p'
fi

printf '\n=== APPROVAL WORKSPACE APPROVE CALL ===\n'
nl -ba client/src/approvals/ApprovalsWorkspace.tsx | sed -n '180,280p'

printf '\n=== APPROVAL API APPROVE CONTRACT ===\n'
nl -ba client/src/approvals/approvalRequestApi.ts | sed -n '208,245p'

printf '\n=== CANONICAL ROUTE BOUNDARY ===\n'
nl -ba server/routes/matilda-canonical-package-route.ts | sed -n '1,120p'

printf '\n=== REVISION CREATOR CONTRACT ===\n'
nl -ba db/matilda-draft-revision-runtime.ts | sed -n '97,180p'

printf '\n=== ASSEMBLER TEST CONTRACT ===\n'
nl -ba db/approval-request-model-assembler.test.ts | sed -n '1,220p'

printf '\n=== APPROVAL ROUTE TESTS ===\n'
find . \
  -path '*/node_modules' -prune -o \
  -path '*/dist' -prune -o \
  -type f \
  \( -name '*approval-request*.test.ts' -o -name '*approval-request*.test.mjs' \) \
  -print

printf '\n=== TRACE APPROVAL COLLECTION CONSTRUCTION ===\n'
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  --exclude-dir=.git \
  -E \
  'assembleApprovalRequest(ReadModel|Collection)|approval-request-model-assembler|fetchApprovalRequests' \
  routes server db client/src 2>/dev/null | head -n 500 || true

printf '\n=== PROVE REVISION CREATOR IDEMPOTENCY CONTRACT ===\n'
grep -n -A24 -B4 \
  'source_draft_updated_at' \
  db/matilda-draft-revision-runtime.ts | head -n 120

printf '\n=== CLASSIFY SMALLEST INTEGRATION ===\n'
node <<'NODE'
const fs = require("fs");

const assembler = fs.readFileSync(
  "db/approval-request-model-assembler.ts",
  "utf8",
);

const revisionRuntime = fs.readFileSync(
  "db/matilda-draft-revision-runtime.ts",
  "utf8",
);

const clientApi = fs.readFileSync(
  "client/src/approvals/approvalRequestApi.ts",
  "utf8",
);

const canonicalRoute = fs.readFileSync(
  "server/routes/matilda-canonical-package-route.ts",
  "utf8",
);

const assemblerHasRevision =
  assembler.includes("draft_revision_id");

const creatorIsIdempotent =
  revisionRuntime.includes("source_draft_updated_at") &&
  revisionRuntime.includes("if (existing)") &&
  revisionRuntime.includes("return mapDraftRevision(existing)");

const clientSendsRevision =
  clientApi.includes("draft_revision_id");

const canonicalRequiresRevision =
  canonicalRoute.includes("req.body?.draft_revision_id");

console.log(
  `APPROVAL_READ_MODEL_HAS_REVISION_ID=${assemblerHasRevision ? "YES" : "NO"}`,
);
console.log(
  `REVISION_CREATOR_IDEMPOTENT_FOR_DRAFT_VERSION=${creatorIsIdempotent ? "YES" : "NO"}`,
);
console.log(
  `CLIENT_APPROVE_SENDS_REVISION_ID=${clientSendsRevision ? "YES" : "NO"}`,
);
console.log(
  `CANONICAL_BOUNDARY_REQUIRES_REVISION_ID=${canonicalRequiresRevision ? "YES" : "NO"}`,
);

if (
  !assemblerHasRevision &&
  creatorIsIdempotent &&
  !clientSendsRevision &&
  canonicalRequiresRevision
) {
  console.log(
    "PROPOSED_INTEGRATION_SHAPE=APPROVAL_REVIEW_BOUNDARY_CREATES_OR_REUSES_REVISION_AND_EXPOSES_EXACT_REVISION_ID",
  );
  console.log(
    "CLIENT_HANDOFF_SHAPE=APPROVE_SENDS_DRAFT_PACKAGE_ID_PLUS_EXACT_REVIEW_REVISION_ID",
  );
  console.log(
    "CANONICAL_BOUNDARY_CHANGE_REQUIRED=NO",
  );
  console.log(
    "AUTHORITY_MODEL_CHANGE_REQUIRED=NO",
  );
} else {
  console.log(
    "PROPOSED_INTEGRATION_SHAPE=NOT_YET_PROVEN",
  );
}
NODE

printf '\n=== VERIFY READ ONLY ===\n'
test "$(git rev-parse HEAD)" = "$PRE_HEAD"
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  db/main.db \
  db/matilda-draft-revision-runtime.ts \
  db/approval-request-model-assembler.ts \
  db/matilda-canonical-package-runtime.ts \
  server/routes/matilda-canonical-package-route.ts \
  routes/api-approval-request.ts \
  client/src/approvals

printf '\n=== STOPPING POINT ===\n'
echo "APPROVAL_REVIEW_REVISION_INTEGRATION_INSPECTION=COMPLETE"
echo "FIX_EXECUTED=NO"
echo "DRAFT_REVISION_CREATED=NO"
echo "DATABASE_MUTATED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "APPROVAL_DECISION_EXECUTED=NO"
echo "CANONICAL_MUTATION=NO"
echo "GOVERNANCE_MUTATION=NO"
echo "AUTHORITY_CHANGE=NO"
echo "DR_RECOVERY_BOUNDARY=$DR_BOUNDARY"
echo "NEXT_ACTION=IF_INTEGRATION_POINT_IS_PROVEN_PRESENT_EXPLICIT_NARROW_IMPLEMENTATION_GATE"
echo "CLEAR_STOPPING_POINT=YES"
