
# Policy Engine Repair Corridor Opening

## Status

Open.

## Reason

Scheduler runtime finalization and production lifecycle integration are closed and guarded. The remaining policy failures are a separate bounded backend corridor.

## In Scope

- server/policy/__tests__/determinism_regression.test.mjs

- server/policy/__tests__/evaluate.test.mjs

- server/policy/__tests__/load_default_policy.test.mjs

- server/policy/__tests__/combine.test.mjs

- server/policy/__tests__/grants.test.mjs

- server/policy implementation files required by those tests

## Out of Scope

- scheduler runtime finalization wiring

- production lifecycle integration

- PM2 rehydration

- Matilda export cleanup

- dashboard guidance tests

- unrelated operational scheduler corridors

## Known failure pattern

Current policy tests show missing expected policy outputs, including undefined decision values where tests expect concrete values such as B, and missing trace objects.

## Boundary

Repair policy evaluation behavior only. Do not introduce scheduler authority, lifecycle authority, routing authority, worker authority, orchestration authority, execution authority, or new production runtime wiring.

## First Objective

Run the focused policy test suite and inspect the policy evaluator, default policy loader, and trace construction path.

