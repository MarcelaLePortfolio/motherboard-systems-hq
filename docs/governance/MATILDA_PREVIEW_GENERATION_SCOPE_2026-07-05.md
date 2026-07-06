
# Matilda Preview Generation Scope

Date: 2026-07-05

## Corridor

Plan Review Ready

→ Preview Generation

→ Explicit Preview Confirmation

## Current Stable Checkpoint

HEAD: 45e8cf23

Latest DR: 20260705_235325

## Objective

Implement the Preview Generation corridor that creates a deterministic, user-visible Preview from a dry-run Execution Plan.

Preview shows what execution would do.

Preview does not authorize execution.

## In Scope

- Explicit preview generation endpoint.

- Preview artifact shape.

- Execution Plan reference.

- Assignment reference.

- Package reference.

- Lineage reference.

- Planned steps.

- Planned mutations.

- Rollback references.

- Reconciliation summary.

- Preview status.

## Out of Scope

- Preview confirmation.

- Execution authorization.

- Cade execution.

- Shell execution.

- Filesystem mutation.

- Database mutation beyond persisting preview records.

## Success Criteria

A runtime call can create a Preview containing:

- preview_id

- execution_plan_id

- assignment_id

- package_id

- lineage_id

- preview_summary

- preview_steps

- preview_mutations

- rollback_references

- reconciliation_summary

- status

- created_at

Generating a Preview must not authorize:

- Preview Confirmation

- Execution Authorization

- Cade execution

## Authority Boundary

Preview is user-visible review material only.

Preview must remain deterministic and non-mutating.

Preview confirmation remains a separate explicit operator event.

Execution authority remains in a later corridor.

## Next Milestone

Implement Preview persistence and validate Preview generation from an existing dry-run Execution Plan.

