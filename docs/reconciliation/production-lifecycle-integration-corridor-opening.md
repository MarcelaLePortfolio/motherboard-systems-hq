
# Production Lifecycle Integration Corridor Opening

## Status

Open.

## Reason

Scheduler runtime finalization readiness/completion is closed and guarded. Remaining backend work proceeds in a separate bounded corridor.

## In Scope

- db/governance-lifecycle-composition.test.ts

- db/governance-lifecycle-integration.test.ts

- server/lifecycle/production-lifecycle-entry-point.test.ts

## Out of Scope

- server/policy/*

- PM2 rehydration

- Matilda export

- Scheduler runtime finalization wiring

## Boundary

Do not introduce new scheduler runtime finalization stages.

Repair only lifecycle composition, lifecycle integration, and lifecycle entry-point authority flow.

## First Objective

Identify the first failing authority handoff in the production lifecycle path.

