
# Matilda Assignment Scope

Date: 2026-07-05

## Corridor

Routing

→ Assignment

→ Execution Eligibility

## Current Stable Checkpoint

HEAD: 79b839e3

Latest DR: 20260705_233431

## Objective

Implement the Assignment corridor that creates an explicit assignment from a validated Routing decision.

Assignment establishes ownership of governed work.

Assignment does not authorize execution.

## In Scope

- Explicit assignment endpoint.

- Assignment persistence.

- Routing reference.

- Package reference.

- Lineage reference.

- Assigned agent.

- Assignment rationale.

- Assignment status.

## Out of Scope

- Cade execution.

- Automatic execution.

- Runtime orchestration.

- Scheduler.

- Atlas readiness scoring.

## Success Criteria

A runtime call can create an Assignment containing:

- assignment_id

- routing_id

- package_id

- lineage_id

- assigned_agent

- assignment_rationale

- assignment_timestamp

- status

- created_at

Creating an Assignment must not authorize:

- Cade execution

## Authority Boundary

Only explicit assignment may create an Assignment.

Assignment establishes execution eligibility only.

Execution authority remains in the next corridor.

## Next Milestone

Implement Assignment persistence and validate Assignment creation from an existing Routing record.

