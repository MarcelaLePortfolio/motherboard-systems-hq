# Enable Approve Button Corridor

## Objective

Activate the Executive Inbox Approve button using the existing Canonical Package runtime.

## Verified Foundation

Already implemented:

- POST /api/matilda/canonical-package
- Canonical Package runtime
- Duplicate protection
- Schema validation
- Approval eligibility validation

No new approval endpoint shall be created.

## Authorized Scope

Client:

- Wire the Approve button to the existing endpoint.
- Display a loading state while approval is in progress.
- Refresh the Executive Inbox after success.
- Remove the approved Reconciled Interpretation Summary from the pending approval list.

Server:

- Supply the authoritative approval actor.
- Do not accept approval_actor from the client.

## Out of Scope

- Request Changes persistence
- Delegation
- Execution
- Additional governance stages
- Identity system redesign

## Success Criteria

✓ Approve button is clickable.
✓ Existing Canonical Package endpoint is used.
✓ Duplicate approvals remain rejected.
✓ Approved item disappears from the Inbox.
✓ No new approval endpoint is introduced.
