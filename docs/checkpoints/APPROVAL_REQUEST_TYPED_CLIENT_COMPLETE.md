# Approval Request Typed Client Completion

- Branch: `feature/new-ui-shell`
- Protected commit: `9c0066e0`
- Status: Complete and pushed

## Verified Outcomes

- Typed Approval Request client implemented.
- Approval Request collection types align with the backend read model.
- Project-scoped API requests use `project_id`.
- Empty project identifiers fail closed.
- Non-success API responses fail closed.
- Client type test passed.
- Client TypeScript build passed.
- Client production build passed.
- Semantic drift guard passed.
- Working tree clean after commit.
- Implementation pushed to `origin/feature/new-ui-shell`.

## Stable End-to-End Read Pipeline

Living Draft Package

↓

Approval Request Repository

↓

Approval Request Read Model

↓

Approval Request Assembler

↓

Approval Request API

↓

Mounted Active Route

↓

Typed Approval Request Client

## Authority Boundary

This corridor remains read-only.

It introduces:

- no new persistence
- no approval execution
- no Canonical Package mutation
- no Preview confirmation
- no Execution Authorization
- no Request Changes
- no notification routing
- no mutation, shell, or autonomous execution authority

## Completed Corridors

- Approval Request repository
- Repository tests
- Approval Request read model
- Approval Request assembler
- Assembler tests
- Approval Request API
- API tests
- Active route registration
- Typed Approval Request client
- Client type tests
- Client production build

## Next Canonical Corridor

Implement the Approval Request provider and hook.

Authorized scope:

- `client/src/approvals/ApprovalRequestProvider.tsx`
- `client/src/approvals/useApprovalRequests.ts`
- provider state management
- provider loading and error handling
- hook
- provider tests if supported by the existing client test environment

Deferred:

- Approvals workspace
- decision execution
- Request Changes
- Preview confirmation
- Execution Authorization
- notification routing
