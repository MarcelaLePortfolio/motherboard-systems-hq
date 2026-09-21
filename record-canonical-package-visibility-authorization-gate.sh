#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="908b3815e"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

cat > docs/checkpoints/CANONICAL_PACKAGE_VISIBILITY_RESTORATION_AUTHORIZATION_GATE.md << 'DOC'
# Canonical Package Visibility Restoration — Authorization Gate

## Conclusion

The investigation established a minimal read-only Canonical Package visibility gap.

Approval, Canonical Package creation, persistence, and exact Draft Revision canonicalization are functioning correctly.

The missing capability is post-approval presentation of approved Canonical Packages in the existing Approvals / Executive Inbox.

## Minimal Implementation Boundary

If explicitly authorized, implementation is limited to:

1. a project-scoped Canonical Package read model;
2. a read-only Canonical Package API;
3. approved Canonical Package presentation inside the existing Approvals / Executive Inbox;
4. preserving pending Approval Requests and approved Canonical Packages as semantically distinct states;
5. no restoration of the Packages tab.

## Protected Boundaries

No change is authorized to:

- Canonical Package creation or persistence semantics;
- approval semantics;
- Request Changes semantics;
- delegation;
- validation;
- envelope construction;
- execution;
- governance;
- authority.

IMPLEMENTATION_AUTHORIZED=NO
PRODUCT_CODE_CHANGED=NO
DATABASE_MUTATED=NO
AUTHORITY_CHANGED=NO
DO_NOT_START_NEW_DOGFOOD_CONVERSATION=YES
NEXT_ACTION=AWAIT_EXPLICIT_IMPLEMENTATION_AUTHORIZATION
CLEAR_STOPPING_POINT=YES
DOC

git diff --check

git add -- docs/checkpoints/CANONICAL_PACKAGE_VISIBILITY_RESTORATION_AUTHORIZATION_GATE.md
git commit -m "Record canonical visibility restoration authorization gate"
git push origin "$BRANCH"

echo
echo "============================================================"
echo " AUTHORIZATION GATE — STOP HERE"
echo "============================================================"
echo "INVESTIGATION_COMPLETE=YES"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "NEXT_ACTION=EXPLICIT_USER_AUTHORIZATION"
echo "CLEAR_STOPPING_POINT=YES"
