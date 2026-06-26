
# Production Lifecycle Surface Contract

## Purpose

Define the smallest production-facing lifecycle surface that can consume an already-created Governance Envelope and invoke the completed Governance Lifecycle Integration Caller.

This contract is a planning artifact only.

It does not authorize implementation.

## Architectural Finding

The governed planning pipeline must terminate before the Governance Lifecycle begins.

The governed planning pipeline operates in the planning artifact domain.

The Governance Lifecycle operates in the canonical governance artifact domain.

These domains must remain separate.

## Surface Role

The Production Lifecycle Surface is a thin production-facing caller.

It consumes an already-created Governance Envelope and invokes the completed lifecycle integration caller.

It does not create Governance Envelopes.

It does not interpret user intent.

It does not define capabilities.

It does not mutate the Envelope.

It does not route work.

It does not schedule work.

It does not claim work.

It does not execute work.

It does not introduce a new architectural authority.

## Input Contract

The surface may accept only the minimum input needed to invoke the completed lifecycle integration caller:

- envelope_id

- envelope lifecycle state

- required capabilities

- operational corridor

- already-authorized Governance Envelope data required by the existing integration caller

The input must represent an already-created Governance Envelope.

## Output Contract

The surface may return only the result of the completed lifecycle integration caller:

- assignment readiness result

- transition authorization result

- lifecycle persistence result

- failed-closed error result when any boundary rejects the transition

## Active Authority Boundary

The surface operates under Lifecycle Authority.

It composes existing boundaries only:

1. Assignment Boundary

2. Lifecycle Transition Authorization Boundary

3. Governance Lifecycle Persistence Boundary

It does not own those boundaries.

It does not expand those boundaries.

## Non-Authorities

The surface is not:

- Database Authority

- Persistence Authority beyond invoking the existing persistence boundary

- Assignment Authority beyond invoking the existing assignment boundary

- Execution Authority

- Orchestration Authority

- Scheduler Authority

- Worker Authority

- Runtime Caller Authority

- Lifecycle Mutation Authority

## Validation Path

A future implementation must validate:

- accepted already-created Governance Envelope input

- rejection of missing envelope input

- rejection of non-ENVELOPE_CREATED lifecycle state

- rejection of missing required capabilities

- rejection of missing operational corridor

- successful ENVELOPE_CREATED to ASSIGNED transition

- no execution performed

- no routing performed

- no scheduler or worker invocation performed

## Rollback Path

Rollback is ordinary git rollback to the last stable checkpoint.

No schema migration should be introduced by this surface.

No data migration should be introduced by this surface.

## Explicitly Out of Scope

This contract does not authorize:

- endpoint creation

- route mounting

- scheduler integration

- worker integration

- orchestration integration

- schema changes

- Envelope contract expansion

- assignment persistence expansion

- assigned actor persistence

- routing history persistence

- autonomous Ellis behavior

- execution authority

- new architectural authority

## Next Canonical Milestone

Implementation readiness assessment for the Production Lifecycle Surface.

That assessment should determine whether implementation can proceed safely as a thin service/caller without endpoint wiring.

