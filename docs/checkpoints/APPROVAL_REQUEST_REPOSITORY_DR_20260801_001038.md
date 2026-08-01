# Approval Request Repository DR Checkpoint

- Branch: `feature/new-ui-shell`
- Protected commit: `0ff4e423`
- DR checkpoint: `20260801_001038`
- Offsite R2 sync: Not configured

## Verified Outcomes

- Approval Request repository implemented.
- Repository is read-only.
- Pending Canonical Package approvals are derived from authoritative runtime state.
- Project-scoped filtering is enforced.
- Canonical Package existence suppresses completed approval requests.
- Repository test passed.
- Semantic drift guard passed.
- Implementation committed and pushed.

## Authority Boundary

The repository:

- introduces no new persistence
- introduces no new runtime authority
- introduces no new approval state
- derives pending approval requests from authoritative Living Draft and Canonical Package state only

The repository does **not**:

- execute approvals
- mutate Canonical Packages
- mutate Living Drafts
- expose Preview confirmation
- expose Execution Authorization
- expose Request Changes
- expose notifications
- expose mutation authority

## Current Architecture

Living Draft
        │
        ▼
Approval Request Repository
        │
        ▼
Approval Request Read Model
        │
        ▼
Read-only API

## Completed Corridor

✔ Approval Request Repository

## Next Canonical Corridor

Implement the Approval Request Read Model / Assembler.

Authorized scope:

- ApprovalRequestReadModel
- assembler
- assembler tests

Deferred:

- API
- client
- provider
- workspace
- decision execution
