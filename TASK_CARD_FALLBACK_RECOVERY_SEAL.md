
# Task Card Fallback Recovery Seal

## Seal timestamp

2026-05-28

## Current validated commit

06c14ef7 Verify task card fallback UI state

## Stabilized task card controls

- Requeue button restored.

- Retry differently button restored.

- Inspect logs button present.

- Status pill fallback restored for all task statuses.

- Retry relationship fallback restored from `payload.meta.retry_of_task_id`.

- Artifact preview fallback restored for artifact data stored under:

  - `t.artifact`

  - `t.artifacts[0]`

  - `t.payload.artifact`

  - `t.payload.artifacts[0]`

  - `t.metadata.artifact`

  - `t.metadata.artifacts[0]`

- Trace fallback restored for trace data stored under:

  - `t.guidance.communicationResult.systemTrace.content`

  - `t.payload.guidance.communicationResult.systemTrace.content`

  - `t.metadata.guidance.communicationResult.systemTrace.content`

  - `t.payload.trace`

  - `t.metadata.trace`

## Important limitation

The current restored database rows do not contain artifact or trace payloads, so Preview and Inspect Trace can only appear when future or restored tasks include those fields.

## Validated runtime evidence

- `/api/tasks?limit=5` returned successfully.

- `/api/tasks/health` returned `{"ok":true}`.

- Dashboard rebuilt and restarted successfully.

- Fallback renderer code was verified present.

- Commit pushed to GitHub.

## Failed / avoided approaches

- Broad SQL JSON-derived `/api/tasks` enrichment caused instability and was reverted.

- Future task response enrichment must proceed one narrow field at a time.

- Do not use health-only verification for `/api/tasks` changes; always verify `/api/tasks?limit=N`.

## Safe boundary

This was a renderer fallback restoration only.

No layout corridor was modified.

No database mutation schema was modified.

No governed execution authority boundary was modified.

