# Executive Inbox Approval Baseline DR

- Branch: `feature/new-ui-shell`
- DR checkpoint: `20260802_010330`
- Status: Stable

## Verified Baseline

- Executive Inbox renders correctly.
- Artifact switching is fully functional.
- Decision controls are present.
- Existing backend is healthy.
- Approval Requests endpoint returns HTTP 200.
- Canonical Package runtime exists.
- Duplicate approval protection exists.
- Client production build succeeds.

## Remaining Gap

The Approve button has not yet been wired to the existing Canonical Package endpoint.

No new approval infrastructure is required.

## Next Authorized Corridor

Implement only the existing approval path.

Client responsibilities:

- Submit the selected `draft_package_id`.
- Display an approving state.
- Refresh the Inbox after success.

Server responsibilities:

- Supply the authoritative approval actor.
- Continue enforcing duplicate protection.
- Do not trust a client-supplied actor.

## Success Criteria

✓ Approve submits successfully.
✓ One Canonical Package is created.
✓ Duplicate approvals remain rejected.
✓ Approved Living Draft disappears from the pending Inbox.
✓ Delegation and execution remain unauthorized.
