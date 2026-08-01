# Approval Request API Completion

- Branch: `feature/new-ui-shell`
- Protected commit: `f445dab2`
- Status: Complete and pushed

## Verified Outcomes

- Approval Request repository remains read-only.
- Approval Request read model remains deterministic.
- Approval Request assembler remains deterministic.
- Read-only Approval Request API implemented.
- API composes repository and assembler without introducing new authority.
- Repository tests passed.
- Assembler tests passed.
- API tests passed.
- Semantic drift guard passed.
- Working tree clean after commit.

## Stable Backend Pipeline

Living Draft Package

↓

Approval Request Repository

↓

Approval Request Read Model

↓

Approval Request Assembler

↓

Approval Request API

## Authority Boundary

The API:

- introduces no persistence
- introduces no mutation
- introduces no execution authority
- introduces no Preview confirmation
- introduces no Execution Authorization
- introduces no Request Changes
- exposes only derived Approval Request projections

## Completed Corridors

- Approval Request Repository
- Repository tests
- Approval Request Read Model
- Approval Request Assembler
- Assembler tests
- Approval Request API
- API tests

## Next Canonical Corridor

Implement the typed Approval Request client.

Authorized scope:

- client/api-approval-request.ts
- client tests
- response typing
- request typing

Deferred:

- provider
- hook
- Approvals workspace
- decision execution
- notification routing
