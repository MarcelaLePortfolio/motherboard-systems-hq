
# PM2 Rehydration Cleanup Corridor Opening

## Status

Open.

## Reason

Scheduler runtime finalization, production lifecycle integration, policy engine repair, and Matilda export cleanup are closed. The remaining repeated failure pattern is PM2 rehydration diagnostics failing when no PM2 processes exist.

## In Scope

- scripts/diagnostics/test-rehydration.ts

- dist/scripts/diagnostics/test-rehydration.js

- test-rehydration.ts

- ts-backup/test-rehydration.ts

- scripts_backup/diagnostics/test-rehydration.ts

- scripts_backup/scripts/diagnostics/test-rehydration.ts

- scripts_backup_2/diagnostics/test-rehydration.ts

- PM2 status assumptions used by rehydration tests

## Out of Scope

- scheduler runtime finalization

- production lifecycle integration

- policy engine

- Matilda export cleanup

- semantic drift guard

- unrelated Cade state tests

## Known failure

Rehydration tests call pm2 restart all and fail when PM2 reports no process found.

## Boundary

Repair diagnostic behavior only. Do not add scheduler, lifecycle, routing, worker, orchestration, execution, persistence, or production runtime authority.

## First Objective

Gather PM2 status and inspect all rehydration test variants before deciding whether the diagnostic should skip, pass closed, or require a fixture when no PM2 processes exist.

