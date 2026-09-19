#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="ee5a13ef3"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== AUTHORIZED IMPLEMENTATION BOUNDARY ===\n'
echo "STRUCTURAL_WORKSPACE_HANDOFF_AUTHORIZED=YES"
echo "AUTHORIZED_BASE=$EXPECTED_HEAD"
echo "AUTHORIZED_PRODUCT_PATH=client/src/approvals/ApprovalsWorkspace.tsx"
echo "AUTHORIZED_CHANGE=PASS_REQUEST_DRAFT_REVISION_ID"
echo "CANONICAL_BOUNDARY_CHANGE_AUTHORIZED=NO"
echo "DELEGATION_CHANGE_AUTHORIZED=NO"
echo "VALIDATION_CHANGE_AUTHORIZED=NO"
echo "ENVELOPE_CHANGE_AUTHORIZED=NO"
echo "EXECUTION_CHANGE_AUTHORIZED=NO"
echo "GOVERNANCE_CHANGE_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE_AUTHORIZED=NO"

printf '\n=== VERIFY EXISTING PARTIAL CONTRACT ===\n'
grep -q 'createDraftRevisionForApprovalReview' \
  db/approval-request-model-assembler.ts
grep -q 'draft_revision_id: revision.draft_revision_id' \
  db/approval-request-model-assembler.ts
grep -q 'draft_revision_id: string;' \
  client/src/approvals/approvalRequestApi.ts
grep -q 'draft_revision_id: normalizedDraftRevisionId' \
  client/src/approvals/approvalRequestApi.ts

printf '\n=== STRUCTURALLY PATCH SINGLE PROVEN CALLSITE ===\n'
python3 <<'PY'
from pathlib import Path
import re

path = Path("client/src/approvals/ApprovalsWorkspace.tsx")
text = path.read_text()

pattern = re.compile(
    r'await\s+approveCanonicalPackage\s*\(\s*'
    r'request\.draft_package_id\s*,?\s*'
    r'\)\s*;'
)

matches = list(pattern.finditer(text))
print(f"PRE_PATCH_STRUCTURAL_MATCH_COUNT={len(matches)}")

if len(matches) != 1:
    raise SystemExit(
        f"Expected exactly one unpatched approve callsite, found {len(matches)}"
    )

replacement = """await approveCanonicalPackage(
        request.draft_package_id,
        request.draft_revision_id,
      );"""

updated, count = pattern.subn(replacement, text, count=1)

if count != 1:
    raise SystemExit(f"Expected exactly one replacement, received {count}")

path.write_text(updated)
PY

printf '\n=== VERIFY EXACT CHANGE ===\n'
git diff --check
git diff -- client/src/approvals/ApprovalsWorkspace.tsx

grep -q 'request.draft_revision_id' \
  client/src/approvals/ApprovalsWorkspace.tsx

printf '\n=== VERIFY PROTECTED BOUNDARIES ===\n'
git diff --exit-code -- \
  db/approval-request-model-assembler.ts \
  client/src/approvals/approvalRequestApi.ts \
  db/matilda-canonical-package-runtime.ts \
  server/routes/matilda-canonical-package-route.ts \
  db/matilda-draft-revision-runtime.ts \
  server/execution \
  server/operational \
  db/governance-execution-approvals.ts \
  db/governance-execution-scopes.ts \
  db/governance-execution-reconciliation-persistence.ts

printf '\n=== TARGETED TESTS ===\n'
npx tsx --test \
  db/approval-request-model-assembler.test.ts \
  routes/api-approval-request.test.ts

printf '\n=== SERVER BUILD ===\n'
npm run build

printf '\n=== CLIENT BUILD ===\n'
npm --prefix client run build

printf '\n=== FINAL CLASSIFICATION ===\n'
echo "DRAFT_REVISION_CREATED_OR_REUSED_AT_REVIEW_BOUNDARY=YES"
echo "DRAFT_REVISION_EXPOSED_IN_READ_MODEL=YES"
echo "CLIENT_API_SUBMITS_DRAFT_REVISION_ID=YES"
echo "WORKSPACE_PASSES_EXACT_DRAFT_REVISION_ID=YES"
echo "CANONICAL_BOUNDARY_CHANGED=NO"
echo "DELEGATION_CHANGED=NO"
echo "VALIDATION_CHANGED=NO"
echo "ENVELOPE_CHANGED=NO"
echo "EXECUTION_CHANGED=NO"
echo "GOVERNANCE_CHANGED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "STATIC_VALIDATION_COMPLETE=YES"
echo "NEXT_ACTION=RUNTIME_VALIDATE_NATURAL_APPROVAL_FLOW"
echo "CLEAR_STOPPING_POINT=YES"
