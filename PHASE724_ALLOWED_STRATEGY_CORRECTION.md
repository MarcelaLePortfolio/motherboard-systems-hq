
# Phase 724 Allowed Strategy Correction

## Objective

Fix the worker execution-contract rejection caused by returning an unsupported strategy.

## Failure Evidence

Worker log showed:

`[worker][execution-contract] INVALID_STRATEGY`

after the natural visual task was claimed.

## Cause

The Phase 724 interpreter branch returned:

`strategy_applied: visual_artifact_generation`

but the execution contract currently allows existing strategy values only.

## Correction

The visual branch now returns:

`strategy_applied: prompt_augmentation`

and preserves visual-specific identity in meta:

`visual_artifact: true`

`visual_artifact_strategy: visual_artifact_generation`

## Preservation

This keeps the execution strategy contract intact while still enabling visual artifact generation.

No changes to renderer, preview route, retry, SSE, DB schema, polling, or Agent Pool behavior.

## Next Step

Rebuild worker, clear or fail the stuck running task safely, then submit a fresh natural visual delegation task.

