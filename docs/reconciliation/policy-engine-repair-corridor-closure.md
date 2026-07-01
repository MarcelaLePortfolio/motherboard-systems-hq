
# Policy Engine Repair Corridor Closure

## Status

Closed.

## Repair commit

bbf3d63b Restore synchronous policy evaluator exports

## Finding

The policy evaluator entrypoint had shifted named evaluator exports toward the async grant-aware wrapper path.

Policy tests and policy callers expected deterministic synchronous named exports from the legacy evaluator.

The repair preserves the async grant-aware default export while restoring synchronous named exports:

- evaluatePolicy

- evaluate

## Validation

Focused policy suite passed:

5 tests

0 failures

Validated files:

- server/policy/__tests__/combine.test.mjs

- server/policy/__tests__/determinism_regression.test.mjs

- server/policy/__tests__/evaluate.test.mjs

- server/policy/__tests__/grants.test.mjs

- server/policy/__tests__/load_default_policy.test.mjs

## Boundary

This corridor did not modify scheduler runtime finalization.

This corridor did not modify production lifecycle integration.

This corridor did not add scheduler, lifecycle, routing, worker, orchestration, execution, or production runtime authority.

## Remaining separate corridors

- PM2 rehydration cleanup

- Matilda export cleanup

- higher-level production lifecycle consumption verification, if still needed

## Decision

Policy engine repair corridor is closed.

