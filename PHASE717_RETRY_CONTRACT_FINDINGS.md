
# Phase 717 Retry Contract Findings

## Confirmed Authoritative Retry Surface

Authoritative route:

- POST /api/delegate-task

Confirmed middleware/components:

- routeRetryExecution -> ACTIVE

- enforceRetryContract -> IMPORTED ONLY (NOT WIRED)

## Confirmed Retry Payload Contract

Retry activation condition:

- body.kind === "retry"

Required fields:

- strategy

- meta.retry_of_task_id

Allowed strategies:

- standard

- fresh-context

Default strategy:

- standard

## Confirmed Retry Execution Mapping

standard:

- execution_mode: standard_retry

- cache_policy: reuse

- memory_scope: preserve

fresh-context:

- execution_mode: rebuild_context

- cache_policy: bypass

- memory_scope: reset_partial

## Critical Architectural Finding

Current retry enforcement is NOT ACTIVE.

server.mjs imports:

- enforceRetryContract

But does NOT apply:

- app.use(enforceRetryContract)

- enforceRetryContract(req,res,next)

- route-level middleware wiring

Current active behavior:

- routeRetryExecution(req.body) only

Meaning:

- retry payloads are transformed

- retry payloads are NOT validated

## Current Safe Conclusion

Retry/requeue UI controls MUST remain non-authoritative.

Reason:

- retry validation contract exists

- retry enforcement wiring incomplete

- mutation path not yet safely enforced

## Next Safe Corridor

1. Wire enforceRetryContract narrowly onto POST /api/delegate-task only.

2. Avoid global middleware attachment.

3. Preserve renderer-scoped UI discipline.

4. Validate under Docker immediately after narrow wiring.

5. Do not enable retry buttons until contract enforcement verified live.

