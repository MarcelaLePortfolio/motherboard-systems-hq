# Approval Request Assembler DR Checkpoint

- Branch: `feature/new-ui-shell`
- Protected commit: `98c3830a`
- DR checkpoint: `20260801_002316`
- Offsite R2 sync: Not configured

## Verified Outcomes

- Approval Request repository implemented and tested.
- Approval Request read model implemented and tested.
- Approval Request assembler implemented and tested.
- Deterministic Approval Request identity established.
- Project-scoped collection assembly enforced.
- Cross-project sources fail closed.
- Invalid evidence JSON fails closed.
- Evidence identifiers are normalized and deduplicated.
- Semantic drift guard passed.
- Repository remains read-only.
- All implementation and documentation commits pushed.

## Authority Boundary

The Approval Request backend currently introduces:

- no new persistence
- no approval execution
- no Canonical Package mutation
- no Preview confirmation
- no Execution Authorization
- no Request Changes
- no notification routing
- no mutation, shell, or autonomous execution authority

Approval Requests remain projections over authoritative runtime state.

## Current Stable Backend Chain

Living Draft Package

↓

Approval Request Repository

↓

Approval Request Read Model

↓

Approval Request Assembler

## Completed Corridors

- Approval Request Repository
- Repository tests
- Approval Request Read Model
- Approval Request Assembler
- Assembler tests
- Repository documentation
- Assembler documentation

## Next Canonical Corridor

Implement the read-only Approval Request API.

Authorized scope:

- `routes/api-approval-request.ts`
- API repository wiring
- API assembler wiring
- API tests
- minimal active-server registration (if required)

Deferred:

- typed client
- provider
- hook
- Approvals workspace
- decision execution
- notification routing
