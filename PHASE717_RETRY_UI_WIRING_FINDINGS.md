
# Phase 717 Retry UI Wiring Findings

## Confirmed Finding

Recent Tasks retry/requeue UI wiring already exists in:

- public/js/phase530_visible_panels_bridge.js

## Confirmed UI Behavior

The lifecycle card buttons call:

- phase717RetryTask(taskId, mode, button, taskTitle)

Modes:

- Requeue -> standard

- Retry differently -> fresh-context

## Confirmed Request Target

Both actions POST to:

- /api/delegate-task

## Confirmed Payload Shape

The UI sends:

{

  "kind": "retry",

  "strategy": "standard | fresh-context",

  "title": "<generated retry title>",

  "meta": {

    "retry_of_task_id": "<task id>"

  },

  "source": "operator-guidance-ui"

}

## Contract Alignment

This matches the validated backend retry contract:

- kind must equal retry

- strategy must be standard or fresh-context

- meta.retry_of_task_id is required

## Current Safe Conclusion

Backend contract enforcement is live.

Frontend retry/requeue wiring appears already present and contract-aligned.

## Next Safe Validation

Validate the served dashboard JS under Docker and confirm:

1. phase717RetryTask exists in served JS.

2. fetch("/api/delegate-task") exists in served JS.

3. kind: "retry" exists in served JS.

4. meta.retry_of_task_id exists in served JS.

5. Recent Tasks buttons remain visible.

6. Manual browser click confirms modal + successful retry submission.

