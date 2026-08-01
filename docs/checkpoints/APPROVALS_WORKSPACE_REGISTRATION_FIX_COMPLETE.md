# Approvals Workspace Registration Fix Completion

- Branch: `feature/new-ui-shell`
- Corrective commit: `9ff8d24b`
- Previous workspace commit: `02bee072`
- Status: Build restored, committed, and pushed

## Verified Outcomes

- `approvals` is now a valid `ShellWorkspace`.
- Approvals navigation is registered.
- The Approvals workspace is reachable from primary navigation.
- `WorkspaceMount` derives the active project through the authoritative Project Registry pattern.
- Active project identity resolves from:
  - `registry.activeProject.projectId`
  - fallback `registry.activeProjectId`
- The Approval Request provider is mounted only when an active project exists.
- The no-active-project state fails closed.
- Client TypeScript validation passed.
- Client production build passed.
- Semantic drift guard passed.
- Corrective implementation committed and pushed to `origin/feature/new-ui-shell`.

## Failure Reconciliation

Commit `02bee072` introduced the read-only Approvals workspace but was committed after a failed client build.

The failure was caused by two incorrect assumptions:

1. `ProjectContextValue` directly exposed `activeProjectId`.
2. `approvals` was already part of the `ShellWorkspace` type.

Commit `9ff8d24b` corrects both assumptions using existing authoritative repository patterns.

## Stable Workspace Chain

NavigationRegion

↓

ShellWorkspace: `approvals`

↓

WorkspaceMount

↓

Project Registry active project identity

↓

ApprovalRequestProvider

↓

ApprovalsWorkspace

## Authority Boundary

The Approvals workspace remains read-only.

It introduces:

- no approval command wiring
- no Canonical Package mutation
- no Request Changes
- no Preview confirmation
- no Execution Authorization
- no notifications
- no mutation, shell, or autonomous execution authority

## Validation

- Client build: passed
- Semantic drift guard: passed
- Corrective scope: two files
- Commit: `9ff8d24b`
- Remote push: complete

## Next Required Step

Run Disaster Recovery after this documentation commit.

The new DR should protect:

- read-only Approvals workspace
- Approvals navigation registration
- active-project provider mounting
- successful client build
- corrective registration commit

## Next Canonical Corridor

After DR, perform browser validation of the read-only Approvals workspace.

Validate:

- Approvals navigation opens the correct workspace.
- Active project changes reload Approval Requests.
- Loading state renders correctly.
- Empty inbox state renders correctly.
- API error and retry state render correctly.
- Pending request list renders correctly when authoritative records exist.
- Selected request detail remains read-only.
- No approval action controls are present.
