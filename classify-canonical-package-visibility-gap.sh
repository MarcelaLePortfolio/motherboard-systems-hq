#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="5d289ff5c"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 5 — CLASSIFICATION\n'
printf '============================================================\n'

echo "APPROVAL_PATH=VALIDATED"
echo "CANONICAL_PACKAGE_PERSISTENCE=VALIDATED"
echo "HISTORICAL_PACKAGES_SURFACE=LIVING_DRAFT_ONLY"
echo "CURRENT_APPROVALS_SOURCE=PENDING_APPROVAL_REQUESTS_ONLY"
echo "DEFECT_CLASS=POST_APPROVAL_PRESENTATION_GAP"
echo "PERSISTENCE_DEFECT=NO"
echo "APPROVAL_DEFECT=NO"
echo "CANONICALIZATION_DEFECT=NO"
echo "PRESENTATION_GAP=YES"

printf '\n=== MINIMAL RESTORATION BOUNDARY ===\n'
echo "RESTORATION_TYPE=READ_ONLY_PRESENTATION_BRIDGE"
echo "REQUIRED_CAPABILITY_1=PROJECT_SCOPED_CANONICAL_PACKAGE_READ_MODEL"
echo "REQUIRED_CAPABILITY_2=READ_ONLY_CANONICAL_PACKAGE_API"
echo "REQUIRED_CAPABILITY_3=APPROVALS_INBOX_APPROVED_CANONICAL_PRESENTATION"
echo "REQUIRED_CAPABILITY_4=PENDING_AND_APPROVED_STATES_REMAIN_DISTINCT"
echo "PACKAGES_TAB_REINTRODUCTION_REQUIRED=NO"

printf '\n=== PROTECTED BOUNDARIES ===\n'
echo "CANONICAL_CREATION_CHANGE=NO"
echo "APPROVAL_SEMANTICS_CHANGE=NO"
echo "REQUEST_CHANGES_CHANGE=NO"
echo "DELEGATION_CHANGE=NO"
echo "VALIDATION_CHANGE=NO"
echo "ENVELOPE_CHANGE=NO"
echo "EXECUTION_CHANGE=NO"
echo "GOVERNANCE_CHANGE=NO"
echo "AUTHORITY_CHANGE=NO"

cat > docs/checkpoints/CANONICAL_PACKAGE_APPROVALS_VISIBILITY_CLASSIFICATION.md << 'DOC'
# Canonical Package Approvals Visibility — Classification

## Conclusion

The approval and canonicalization path is functioning.

The approved Canonical Package is durably persisted, but the current Approvals workspace reads pending Approval Requests only. When approval resolves the pending request, the artifact disappears from the current executive presentation even though the Canonical Package continues to exist.

## Historical Finding

The historical Packages read surface was Living-Draft-only.

It read from `matilda_living_draft_packages`, exposed `living_draft` artifacts, and classified them as `needs_review`.

The evidence does not establish that the historical Packages workspace displayed approved Canonical Packages.

Therefore the old Packages workspace must not simply be restored as a substitute for the missing canonical read presentation.

## Classification

DEFECT_CLASS=POST_APPROVAL_PRESENTATION_GAP
PERSISTENCE_DEFECT=NO
APPROVAL_DEFECT=NO
CANONICALIZATION_DEFECT=NO
PRESENTATION_GAP=YES

## Minimal Restoration Boundary

The smallest restoration is a read-only presentation bridge:

1. project-scoped Canonical Package read model;
2. read-only Canonical Package API;
3. approved Canonical Package presentation inside the existing Approvals / Executive Inbox;
4. pending Approval Requests and approved Canonical Packages remain semantically distinct;
5. no Packages-tab restoration is required.

## Protected Boundaries

No change is required to Canonical Package creation, approval semantics, Request Changes, delegation, validation, envelope construction, execution, governance, or authority.

IMPLEMENTATION_AUTHORIZED=NO
DO_NOT_START_NEW_DOGFOOD_CONVERSATION=YES
NEXT_ACTION=EXPLICIT_MINIMAL_READ_ONLY_RESTORATION_AUTHORIZATION_REQUIRED
CLEAR_STOPPING_POINT=YES
DOC

git diff --check

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 5 — COMPLETE\n'
printf '============================================================\n'
echo "POINT_5_CLASSIFICATION=MINIMAL_READ_ONLY_CANONICAL_PACKAGE_VISIBILITY_GAP"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "DO_NOT_START_NEW_DOGFOOD_CONVERSATION=YES"
echo "NEXT_ACTION=EXPLICIT_IMPLEMENTATION_AUTHORIZATION_REQUIRED"
echo "CLEAR_STOPPING_POINT=YES"

git add -- docs/checkpoints/CANONICAL_PACKAGE_APPROVALS_VISIBILITY_CLASSIFICATION.md
git commit -m "Classify canonical package visibility gap"
git push origin "$BRANCH"

git add -- classify-canonical-package-visibility-gap.sh
git commit -m "Record canonical visibility classification procedure"
git push origin "$BRANCH"
