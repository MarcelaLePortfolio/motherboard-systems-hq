
# Phase 717 — Retry Contract Verified

Status: VERIFIED UNDER ACTIVE DOCKER DASHBOARD RUNTIME

Verified safe UI-facing route:

POST /api/delegate-task

Verified payload shape:

{

  "kind": "retry",

  "strategy": "fresh-context",

  "title": "Controlled retry contract probe",

  "meta": {

    "retry_of_task_id": "<original_task_id>"

  },

  "source": "operator-guidance-ui"

}

Verified behavior:

- Active Docker dashboard uses server.js.

- /api/delegate-task applies enforceRetryContract.

- /api/delegate-task applies routeRetryExecution.

- routeRetryExecution maps fresh-context retries to:

  - execution_mode: rebuild_context

  - cache_policy: bypass

  - memory_scope: reset_partial

- /api/delegate-task forwards safely into /api/tasks/create.

- Probe successfully created task:

  - t_bf57fc6c-c733-407e-9b3d-f813d1bdbb91

- Created task appeared in /api/tasks.

Conclusion:

Lifecycle-card retry controls may now be wired to POST /api/delegate-task, but only as explicit operator-triggered actions.

Controls must not use /api/tasks/create directly from the UI.

Controls must not trigger silently.

Controls must preserve advisory/chat execution isolation.

