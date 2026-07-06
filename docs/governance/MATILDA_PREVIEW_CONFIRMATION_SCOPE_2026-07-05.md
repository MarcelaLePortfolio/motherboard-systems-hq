
# Matilda Preview Confirmation Scope

Date: 2026-07-05

## Corridor

Preview Ready

→ Explicit Preview Confirmation

→ Execution Authorization Pending

## Current Stable Checkpoint

HEAD: 52ec8229

Latest DR: 20260705_235810

## Objective

Implement explicit operator Preview Confirmation for a generated Preview.

Confirmation records that the operator has reviewed the Preview and confirmed that it accurately represents intended execution.

Confirmation does not authorize execution.

## In Scope

- Explicit confirmation endpoint.

- Preview reference.

- Execution Plan reference.

- Package reference.

- Lineage reference.

- Confirmation actor.

- Confirmation timestamp.

- Confirmation status.

## Out of Scope

- Execution Authorization.

- Cade execution.

- Shell execution.

- Filesystem mutation.

- Runtime orchestration.

## Success Criteria

A runtime call can create a Preview Confirmation containing:

- confirmation_id

- preview_id

- execution_plan_id

- package_id

- lineage_id

- confirmation_actor

- confirmation_timestamp

- confirmation_result

- status

- created_at

Creating a Preview Confirmation must not authorize:

- Execution Authorization

- Cade execution

## Authority Boundary

Only explicit operator confirmation may create a Preview Confirmation.

Preview Confirmation establishes execution-authorization eligibility only.

Execution authority remains in the next corridor.

## Next Milestone

Implement Preview Confirmation persistence and validate explicit Preview Confirmation from an existing Preview.

