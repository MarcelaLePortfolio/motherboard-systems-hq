
# Matilda Export Cleanup Corridor Opening

## Status

Open.

## Reason

Scheduler runtime finalization, production lifecycle integration, and policy engine repair are closed. The remaining Matilda failure is isolated to a missing export and should be repaired as a separate small corridor.

## In Scope

- test/matilda-delegate.ts

- scripts/agents/matilda*

- any directly required Matilda export surface

## Out of Scope

- scheduler runtime finalization

- production lifecycle integration

- policy engine

- PM2 rehydration

- backup scripts

- governance lifecycle wiring

## Known failure

test/matilda-delegate.ts imports matildaTaskRunner from ../scripts/agents/matilda, but that module does not provide the named export.

## Boundary

Repair the Matilda export surface only. Do not add execution, scheduler, routing, lifecycle, worker, orchestration, or persistence authority.

## First Objective

Inspect the Matilda test and module export shape, then add the smallest compatible export.

