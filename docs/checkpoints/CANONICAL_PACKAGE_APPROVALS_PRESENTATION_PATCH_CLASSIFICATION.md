# Canonical Package Approvals Presentation — Minimal Patch Classification

## Classification

The existing Approvals / Executive Inbox already owns the pending Approval Request presentation and receives its project binding through `ApprovalRequestProvider`.

The authorized Canonical Package read bridge supplies the corresponding project-scoped approved state.

The minimal presentation patch is therefore:

1. extend `ApprovalRequestProvider` to fetch and expose the read-only Canonical Package collection using the same existing `projectId`;
2. preserve the existing pending Approval Request collection unchanged;
3. present approved Canonical Packages in `ApprovalsWorkspace` as a distinct `Approved` state;
4. provide a read-only approved-package detail presentation;
5. retain `Approve` and `Request Changes` exclusively on pending Approval Requests.

No new project context, top-level workspace, or Packages tab is required.

## Semantic Separation

Pending Approval Requests remain actionable decision objects with the `Needs review` state.

Approved Canonical Packages are authoritative read-only records with the `Approved` state.

Approved Canonical Packages must not expose:

- Approve;
- Request Changes;
- available decisions;
- delegation controls;
- execution controls;
- any mutation action.

## Protected Boundaries

No change is required or authorized to:

- Canonical Package creation or persistence;
- approval semantics;
- Request Changes semantics;
- delegation;
- validation;
- envelope construction;
- execution;
- governance;
- authority.

Approval remains distinct from delegation and execution.

IMPLEMENTATION_SCOPE=AUTHORIZED_APPROVED_CANONICAL_PRESENTATION
PRODUCT_CODE_CHANGED=NO
DATABASE_MUTATED=NO
AUTHORITY_CHANGED=NO
PACKAGES_TAB_RESTORED=NO
NEXT_ACTION=IMPLEMENT_BOUNDED_APPROVALS_PRESENTATION_PATCH
CLEAR_STOPPING_POINT=YES
