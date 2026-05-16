
# Phase 724 Running Task Diagnostic

## Objective

Diagnose why the natural visual delegation task remained in `running` state.

## Target Task

`t_a31dd996-d458-4ae3-96ae-6729d310f92f`

## Known State

The task title persisted correctly:

`Create a visual launch card for Moonrise Bakery`

The task did not complete during the first check and remained:

`running`

## Diagnostic Scope

Inspect:

- worker logs

- task row status

- claimed_by

- updated_at

- run_id

- payload

## Interpretation

If worker logs show an exception, fix the worker patch.

If worker is alive but task is stale, inspect claim/complete lifecycle before retrying.

If the visual task caused worker completion failure, revert or patch the interpreter output safely.

## Contract Boundary

Do not modify renderer, preview route, retry contract, SSE, DB schema, polling, or Agent Pool behavior during this diagnostic.

