# Executive Inbox Interaction Parity

## Objective

Bring the Executive Inbox to interaction parity with the Packages workspace.

Presentation is now sufficiently aligned.

This corridor restores the remaining review workflow behavior.

## Required Behaviors

Selecting an inbox item must:

- update the executive briefing
- visually move the active selection
- preserve scroll position
- update every artifact-specific field
- update evidence references
- update requested outcome
- update proposed work
- update proposed artifacts
- update scope
- update constraints
- update technical metadata

The detail pane must never remain bound to stale data after another inbox item is selected.

## Scope

Authorized files:

- client/src/approvals/ApprovalsWorkspace.tsx

No CSS changes unless required for a bug fix.

No backend changes.

No provider changes.

No API changes.

No approval actions.

No mutation.

No Packages removal.

## Validation

- Selecting every inbox row updates the entire briefing.
- No stale values remain after switching.
- The selected row indicator follows the active artifact.
- Browser behavior matches Packages.
