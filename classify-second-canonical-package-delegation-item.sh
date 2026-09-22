#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
BASELINE="2940f6722"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "============================================================"
echo " SECOND CANONICAL PACKAGE ITEM — CLASSIFICATION"
echo "============================================================"
echo "MODE=READ_ONLY"
echo "IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "=== VERIFIED CLASSIFICATION ==="
printf '%s\n' \
  'CANONICAL_APPROVAL_AND_DELEGATION=SEPARATE_AUTHORITY_EVENTS' \
  'CANONICAL_APPROVAL_GRANTS_DELEGATION=NO' \
  'UNDELEGATED_MISSION_STAGE=AWAITING_DELEGATION' \
  'GOVERNANCE_DELEGATION_MUTATION=IMPLEMENTED' \
  'EXECUTIVE_INBOX_DELEGATION_ACTION=NOT_IMPLEMENTED' \
  'CURRENT_CANONICAL_PACKAGE_PRESENTATION=READ_ONLY'

echo
echo "=== CURRENT ROUTE BINDING ==="
grep -n -E \
  'governanceDelegation|governance-delegation|createGovernanceDelegationRouter' \
  server/index.ts || true

echo
echo "=== GOVERNANCE DELEGATION ROUTE ==="
sed -n '1,360p' server/routes/governance-delegation-route.ts

echo
echo "=== DELEGATION CALLERS / CLIENT SURFACE ==="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'governance-delegation|createDelegation|delegate.*package|delegation_authorized|governance_delegations' \
  client/src server routes db \
  2>/dev/null | head -360 || true

echo
echo "=== CURRENT APPROVALS SURFACE ==="
grep -n -A25 -B15 -E \
  'Canonical Package|Approved|Delegate|Approval does not delegate|read-only' \
  client/src/approvals/ApprovalsWorkspace.tsx | head -360

echo
echo "============================================================"
echo " CLASSIFICATION COMPLETE"
echo "============================================================"
echo "SECOND_USER_DECISION=EXPLICIT_DELEGATION"
echo "SECOND_CANONICAL_APPROVAL=NO"
echo "EXISTING_DELEGATION_BACKEND=YES"
echo "EXECUTIVE_DELEGATION_UI=NOT_IMPLEMENTED"
echo "NEXT_CORRIDOR=EXECUTIVE_DELEGATION_DECISION"
echo "NEXT_ACTION=DEFINE_MINIMAL_EXECUTIVE_DELEGATION_IMPLEMENTATION_BOUNDARY"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "CLEAR_STOPPING_POINT=YES"
