# Packages Workspace V1 — Claude Handoff

## Repository State

- Repository: motherboard-systems-hq-clean
- Branch: feature/new-ui-shell
- Baseline commit: e5acb120
- DR checkpoint: 20260731_131955

## Objective

Replace the existing Packages placeholder with a read-only Packages workspace that consumes the completed Package Read provider.

## Completed Runtime Foundation

The following runtime layers are complete and should be treated as authoritative:

- Packages sidebar destination
- Project-scoped Package Read repository
- Executive Package Read model
- Package Read API
- Typed Package Read client
- Package Read provider
- usePackages() hook

These layers are not to be modified.

## Workspace Responsibilities

Claude should implement presentation only.

The workspace should:

- Render Packages for the active project.
- Display loading, empty, ready, and error states.
- Display Living Draft Packages.
- Allow selecting a Package.
- Display Package detail.
- Display refresh capability.
- Clearly communicate that Living Draft Packages are not authoritative.

## Out of Scope

Do not modify:

- backend
- database
- Package Read repository
- Package Read model
- Package Read API
- typed client
- Package Read provider
- Project Context
- Mission Control
- Matilda Chat
- notifications
- approvals
- governance
- execution
- package mutation

## Preferred Files

- client/src/packages/PackagesWorkspace.tsx
- client/src/packages/packages-workspace.css
- client/src/shell/WorkspaceMount.tsx

## Acceptance Criteria

- Packages tab opens the new workspace.
- Active project packages render correctly.
- Project switching refreshes correctly.
- Loading, empty, and error states are implemented.
- Selecting a package displays detail.
- No approval controls exist.
- No runtime contract changes.
- Client type-check passes.
- Client build passes.
- Semantic drift guard passes.
