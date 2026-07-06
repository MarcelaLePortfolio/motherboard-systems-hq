
# Matilda Routing Scope

Date: 2026-07-05

## Corridor

Envelope Creation

→ Routing

→ Assignment Eligibility

## Current Stable Checkpoint

HEAD: 262ab7d8

Latest DR: 20260705_232816

## Objective

Implement the Routing corridor that creates an explicit routing decision from a validated Envelope.

Routing determines the destination for governed work.

Routing does not authorize assignment or execution.

## In Scope

- Explicit routing endpoint.

- Routing persistence.

- Envelope reference.

- Package reference.

- Lineage reference.

- Routing destination.

- Routing rationale.

- Routing status.

## Out of Scope

- Assignment.

- Cade execution.

- Scheduler runtime.

- Automatic execution.

- Atlas readiness scoring.

## Success Criteria

A runtime call can create a Routing record containing:

- routing_id

- envelope_id

- package_id

- lineage_id

- routing_destination

- routing_rationale

- routing_timestamp

- status

- created_at

Creating a Routing record must not authorize:

- Assignment

- Cade execution

## Authority Boundary

Only explicit routing may create a Routing record.

Routing establishes assignment eligibility only.

Execution authority remains in later corridors.

## Next Milestone

Implement Routing persistence and validate Routing creation from an existing Envelope.

