
# Matilda Execution Authorization Scope

Date: 2026-07-06

## Corridor

Explicit Preview Confirmation

→ Execution Authorization

→ Cade Execution Eligibility

## Current Stable Checkpoint

HEAD: ec952881

Latest DR: 20260706_000422

## Objective

Implement explicit operator Execution Authorization after Preview Confirmation.

Execution Authorization records that the operator has explicitly authorized mutation-capable execution consideration.

Execution Authorization does not itself execute Cade.

## In Scope

- Explicit execution authorization endpoint.

- Preview Confirmation reference.

- Preview reference.

- Execution Plan reference.

- Package reference.

- Lineage reference.

- Authorization actor.

- Authorization timestamp.

- Authorization result.

- Authorization status.

## Out of Scope

- Cade execution.

- Shell execution.

- Filesystem mutation.

- Runtime orchestration.

- Scheduler execution.

- Automatic execution.

## Success Criteria

A runtime call can create an Execution Authorization containing:

- authorization_id

- confirmation_id

- preview_id

- execution_plan_id

- package_id

- lineage_id

- authorization_actor

- authorization_timestamp

- authorization_result

- status

- created_at

Creating an Execution Authorization must not perform:

- Cade execution

- shell execution

- filesystem mutation

- database mutation beyond persisting the authorization artifact

## Authority Boundary

Only explicit operator authorization may create an Execution Authorization.

Execution Authorization establishes Cade execution eligibility only.

Actual Cade execution remains a separate corridor.

## Next Milestone

Implement Execution Authorization persistence and validate explicit authorization from an existing Preview Confirmation.

