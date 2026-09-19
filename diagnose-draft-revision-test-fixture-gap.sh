#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="160ff1f62"
PRE_HEAD="$(git rev-parse HEAD)"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== FAILURE CLASSIFICATION ===\n'
echo "WORKSPACE_STRUCTURAL_HANDOFF=IMPLEMENTED"
echo "WORKSPACE_PATCH_FAILURE=NO"
echo "TARGETED_TESTS=FAILED"
echo "SERVER_BUILD_RUN=NO"
echo "CLIENT_BUILD_RUN=NO"
echo "OBSERVED_FAILURE=LIVING_DRAFT_PACKAGE_NOT_FOUND"
echo "PRODUCT_FIX_AUTHORIZED=NO"
echo "MODE=READ_ONLY_DIAGNOSIS"

printf '\n=== CURRENT WORKSPACE HANDOFF ===\n'
nl -ba client/src/approvals/ApprovalsWorkspace.tsx | sed -n '188,202p'

printf '\n=== ASSEMBLER REVISION CREATION ===\n'
nl -ba db/approval-request-model-assembler.ts | sed -n '85,110p'

printf '\n=== REVISION RUNTIME PRECONDITION ===\n'
nl -ba db/matilda-draft-revision-runtime.ts | sed -n '85,125p'

printf '\n=== LIVING DRAFT READ CONTRACT ===\n'
nl -ba db/matilda-living-draft-read-runtime.ts | sed -n '1,65p'

printf '\n=== ASSEMBLER TEST FIXTURES ===\n'
nl -ba db/approval-request-model-assembler.test.ts | sed -n '1,125p'

printf '\n=== API TEST FIXTURES ===\n'
nl -ba routes/api-approval-request.test.ts | sed -n '120,185p'

printf '\n=== SEARCH EXISTING TEST FIXTURE PATTERNS ===\n'
grep -RIn \
  -E 'matilda_living_draft_packages|draft-hq-pending|draft-api-pending|draft-1|createLivingDraft|upsert.*LivingDraft|persist.*LivingDraft' \
  db routes server \
  --include='*.test.ts' \
  --include='*.ts' \
  | head -n 300 || true

printf '\n=== CLASSIFY PRECONDITION GAP ===\n'
python3 <<'PY'
from pathlib import Path

assembler_test = Path(
    "db/approval-request-model-assembler.test.ts"
).read_text()

api_test = Path(
    "routes/api-approval-request.test.ts"
).read_text()

revision_runtime = Path(
    "db/matilda-draft-revision-runtime.ts"
).read_text()

signals = {
    "ASSEMBLER_FIXTURE_DRAFT_HQ_PENDING":
        "draft-hq-pending" in assembler_test,
    "ASSEMBLER_FIXTURE_DRAFT_1":
        "draft-1" in assembler_test,
    "API_FIXTURE_DRAFT_API_PENDING":
        "draft-api-pending" in api_test,
    "REVISION_CREATION_READS_LIVING_DRAFT":
        "getLivingDraftPackageById" in revision_runtime,
}

for key, value in signals.items():
    print(f"{key}={'YES' if value else 'NO'}")

if all(signals.values()):
    print(
        "PROVISIONAL_FAILURE_CLASS="
        "TEST_FIXTURES_DO_NOT_SATISFY_REVIEW_REVISION_PRECONDITION"
    )
    print(
        "PREFERRED_NEXT_SCOPE="
        "TEST_FIXTURE_REPAIR_ONLY_PENDING_EVIDENCE_REVIEW"
    )
else:
    print(
        "PROVISIONAL_FAILURE_CLASS="
        "REQUIRES_FURTHER_REASSESSMENT"
    )
PY

printf '\n=== VERIFY READ ONLY ===\n'
test "$(git rev-parse HEAD)" = "$PRE_HEAD"
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  client/src/approvals/ApprovalsWorkspace.tsx \
  client/src/approvals/approvalRequestApi.ts \
  db/approval-request-model-assembler.ts \
  db/matilda-draft-revision-runtime.ts \
  db/matilda-canonical-package-runtime.ts \
  server/routes/matilda-canonical-package-route.ts \
  server/execution \
  server/operational \
  db/governance-execution-approvals.ts \
  db/governance-execution-scopes.ts \
  db/governance-execution-reconciliation-persistence.ts

printf '\n=== STOPPING POINT ===\n'
echo "DIAGNOSIS_COMPLETE=YES"
echo "ADDITIONAL_FIX_ATTEMPTED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "NEXT_ACTION=IF_FIXTURE_GAP_CONFIRMED_DEFINE_TEST_ONLY_REPAIR_BOUNDARY"
echo "CLEAR_STOPPING_POINT=YES"
