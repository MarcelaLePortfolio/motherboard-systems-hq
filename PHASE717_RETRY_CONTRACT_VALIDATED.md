
# Phase 717 Retry Contract Validated

## Commit

Validated at:

- 332da6bc Phase 717: add retry contract live validation

## Runtime Validation

Docker rebuild:

- PASS

Container state:

- dashboard: running

- postgres: healthy

- worker: running

## Retry Contract Enforcement

Valid retry payload:

- POST /api/delegate-task

- kind: retry

- strategy: fresh-context

- meta.retry_of_task_id present

- result: accepted

Invalid retry payload:

- POST /api/delegate-task

- kind: retry

- missing meta.retry_of_task_id

- result: 400 Bad Request

- error: MISSING_RETRY_CONTEXT

## Architectural Result

Retry contract enforcement is now live on the delegate-task route.

Confirmed safe properties:

- express.json runs before delegate-task route

- duplicate post-listen delegate-task override removed

- enforceRetryContract attached narrowly to POST /api/delegate-task

- routeRetryExecution runs after validation

- invalid retry payloads are rejected

## Remaining Constraint

Retry/requeue UI buttons should still remain inactive until the frontend wiring is implemented narrowly and verified.

## Next Safe Corridor

Wire Recent Tasks retry button to POST /api/delegate-task using the validated payload:

{

  "kind": "retry",

  "title": "<original task title>",

  "agent": "<original task agent>",

  "notes": "<retry notes>",

  "strategy": "standard",

  "meta": {

    "retry_of_task_id": "<original task id>"

  }

}

Keep requeue/fresh-context separate unless intentionally added as a second strategy.

