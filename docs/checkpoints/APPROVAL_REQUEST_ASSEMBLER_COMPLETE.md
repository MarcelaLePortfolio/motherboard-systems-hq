# Approval Request Read Model Assembler Completion

- Branch: `feature/new-ui-shell`
- Protected commit: `c395e296`
- Status: Complete and pushed

## Verified Outcomes

- Approval Request repository test passed.
- Approval Request assembler tests passed.
- Deterministic Approval Request identity derived from `draft_package_id`.
- Project-scoped collection assembly enforced.
- Cross-project sources fail closed.
- Invalid evidence JSON fails closed.
- Evidence identifiers deduplicated.
- Semantic drift guard passed.
- Working tree clean after commit.

## Stabilized Read Model

The Approval Request read model now exposes:

- approval_request_id
- kind
- status
- project ownership
- conversation ownership
- lineage ownership
- Living Draft identity
- executive question
- available decisions
- evidence
- timestamps

Current values:

- kind: `canonical_package_approval`
- status: `pending`
- available decision: `approve_canonical_package`

## Authority Boundary

This corridor introduces:

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
- Approval Request repository tests
- Approval Request read model
- Approval Request assembler
- Approval Request assembler tests

## Next Canonical Corridor

Implement the read-only Approval Request API.

Authorized scope:

- API route
- API repository wiring
- API tests
- active server registration (if required)

Deferred:

- typed client
- provider
- hook
- Approvals workspace
- decision-action wiring
