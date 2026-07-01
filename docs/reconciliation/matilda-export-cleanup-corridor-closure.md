
# Matilda Export Cleanup Corridor Closure

## Status

Closed.

## Repair commit

dd325c76 Restore Matilda task runner export

## Finding

test/matilda-delegate.ts imports matildaTaskRunner from ../scripts/agents/matilda.

That path resolves to scripts/agents/matilda/index.ts, which did not provide the named export.

## Repair

Restored a minimal matildaTaskRunner export from scripts/agents/matilda/index.ts.

The export returns the existing stub-safe task response and is also wired as the Matilda handler.

## Validation

Focused Matilda export test passed:

1 test

0 failures

Validated file:

- test/matilda-delegate.ts

## Boundary

This corridor did not add scheduler authority.

This corridor did not add lifecycle authority.

This corridor did not add routing, worker, orchestration, persistence, or execution authority.

## Remaining separate corridors

- PM2 rehydration cleanup

- higher-level production lifecycle consumption verification, if still needed

## Decision

Matilda export cleanup corridor is closed.

