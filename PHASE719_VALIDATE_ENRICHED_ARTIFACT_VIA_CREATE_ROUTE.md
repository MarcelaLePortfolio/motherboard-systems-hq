
# PHASE 719 — VALIDATE ENRICHED ARTIFACT VIA CREATE ROUTE

## PURPOSE

Retry worker markdown enrichment validation using the active task creation route:

`POST /api/tasks/create`

## PREVIOUS FAILURE

`POST /api/tasks` failed because that route is not active for task creation in this runtime.

## SAFETY

Validation only.

No code mutation.

