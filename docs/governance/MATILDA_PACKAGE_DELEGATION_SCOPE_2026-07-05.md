
# Matilda Package Delegation Scope

Date: 2026-07-05

## Corridor

Canonical Package

→ Explicit Delegation

→ Pending Governance Validation

## Current Stable Checkpoint

HEAD: 43e35013

Latest DR: 20260705_231153

## Objective

Implement the delegation corridor that allows an operator to explicitly delegate an existing Canonical Package.

Delegation is distinct from approval.

Approval creates approved meaning.

Delegation authorizes the approved Package to enter downstream governance processing.

## In Scope

- Explicit delegation endpoint.

- Delegation persistence.

- Delegation actor.

- Delegation timestamp.

- Delegation target.

- Package reference.

- Package lineage reference.

- Pending Governance Validation state.

## Out of Scope

- Governance Validation.

- Envelope creation.

- Routing.

- Assignment.

- Cade execution.

- Atlas readiness scoring.

- Automatic repository mutation.

## Success Criteria

A runtime call can create a Delegation containing:

- delegation_id

- package_id

- lineage_id

- delegated_by

- delegation_target

- authorization_state

- authorization_timestamp

- status

Creating a Delegation must not authorize:

- Governance Validation completion

- Envelope creation

- Routing

- Assignment

- Cade execution

## Authority Boundary

Only explicit operator delegation may create a Delegation.

Matilda may present delegation candidates.

Matilda may not self-delegate.

Delegation authorizes downstream governance processing, not execution.

## Next Milestone

Implement Canonical Package delegation persistence and validate explicit delegation from an existing Canonical Package.

