#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="441700149"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "============================================================"
echo " APPROVED CANONICAL PACKAGE — BLANK RENDER DIAGNOSIS"
echo "============================================================"

echo
echo "=== APPROVED PACKAGE SELECTION / DETAIL RENDER ==="
grep -n -B 20 -A 80 \
  -E 'selectedApprovedPackage|selectedApprovedPackageId|Approved.*Brief|onDelegated|delegation' \
  client/src/approvals/ApprovalsWorkspace.tsx || true

echo
echo "=== CANONICAL PACKAGE READ TYPE ==="
sed -n '1,320p' client/src/approvals/canonicalPackageReadApi.ts

echo
echo "=== DELEGATION API ==="
sed -n '1,320p' client/src/approvals/governanceDelegationApi.ts

echo
echo "=== READ REPOSITORY DELEGATION PROJECTION ==="
grep -n -B 30 -A 100 \
  -E 'awaiting_delegation|delegated|ambiguous|delegation' \
  db/canonical-package-read-repository.ts || true

echo
echo "=== POTENTIAL RENDER-TIME PROPERTY ACCESSES ==="
grep -n \
  -E 'pkg\.|delegation\.|selectedApprovedPackage\.' \
  client/src/approvals/ApprovalsWorkspace.tsx || true

echo
echo "=== EXISTING APPROVAL WORKSPACE TEST COVERAGE ==="
find client/src/approvals -maxdepth 1 -type f -name '*test*' -print | sort
grep -Rni \
  -E 'selectedApprovedPackage|ApprovedBrief|Delegate|Delegated|awaiting_delegation' \
  client/src/approvals/*test* 2>/dev/null || true

echo
echo "=== BUILD STATE ==="
npm run build
(
  cd client
  npm run build
)

echo
echo "=== REPOSITORY STATE ==="
git status --short

echo
echo "BROWSER_OBSERVATION=APPROVED_PACKAGE_SELECTION_BLANKS_PAGE"
echo "LIST_SURFACE_RENDERED=YES"
echo "APPROVED_DETAIL_RENDER_VALIDATED=NO"
echo "END_TO_END_BROWSER_VALIDATION=FAILED"
echo "PRODUCT_MUTATION_PERFORMED=NO"
echo "DATABASE_MUTATION_PERFORMED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=CLASSIFY_RENDER_FAILURE_FROM_DIAGNOSTIC_EVIDENCE"
echo "CLEAR_STOPPING_POINT=YES"
