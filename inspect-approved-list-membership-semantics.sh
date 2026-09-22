#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="bdefa5fd2"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "============================================================"
echo " EXECUTIVE DELEGATION — APPROVED LIST MEMBERSHIP INSPECTION"
echo "============================================================"

echo
echo "=== APPROVAL WORKSPACE PACKAGE COLLECTIONS / FILTERS ==="
grep -n -B 12 -A 24 \
  -E 'approvedPackages|canonicalCollection|canonicalPackages|filter\(.*delegation|delegation\.state|fetchCanonicalPackages' \
  client/src/approvals/ApprovalsWorkspace.tsx \
  client/src/approvals/ApprovalRequestProvider.tsx \
  client/src/approvals/canonicalPackageReadApi.ts \
  || true

echo
echo "=== APPROVED LIST RENDERING ==="
grep -n -B 20 -A 50 \
  -E 'Approved|approvedPackages|selectedApprovedPackage' \
  client/src/approvals/ApprovalsWorkspace.tsx \
  || true

echo
echo "=== CANONICAL PACKAGE SERVER READ SEMANTICS ==="
grep -n -B 15 -A 45 \
  -E "status = 'canonical_approved'|listByProject|delegationStatement|readDelegationState" \
  db/canonical-package-read-repository.ts \
  || true

echo
echo "=== EXISTING TESTS ABOUT LIST MEMBERSHIP ==="
grep -Rni \
  --include='*test*.ts' \
  --include='*test*.tsx' \
  -E 'approved.*delegat|delegat.*approved|awaiting_delegation|delegated.*filter|Approved' \
  client/src/approvals db \
  || true

echo
echo "=== LIVE PACKAGE STATE AFTER DELEGATION ==="
curl -sS \
  "http://localhost:3000/api/canonical-packages?project_id=hq" \
  || true

echo
echo
echo "=== CLASSIFICATION BOUNDARY ==="
echo "LIVE_OBSERVATION=DELEGATED_PACKAGE_REMAINS_IN_APPROVED_LIST"
echo "INVESTIGATION_ONLY=YES"
echo "PRODUCT_MUTATION_PERFORMED=NO"
echo "DATABASE_MUTATION_PERFORMED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "FIX_AUTHORIZED=NO"
echo "NEXT_ACTION=CLASSIFY_APPROVED_LIST_MEMBERSHIP_FROM_EVIDENCE"
echo "CLEAR_STOPPING_POINT=YES"
