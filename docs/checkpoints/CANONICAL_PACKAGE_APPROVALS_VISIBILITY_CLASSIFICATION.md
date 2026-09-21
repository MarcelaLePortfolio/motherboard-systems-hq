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
