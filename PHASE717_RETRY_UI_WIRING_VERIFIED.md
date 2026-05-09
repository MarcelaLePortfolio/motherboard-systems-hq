
# Phase 717 — Retry UI Wiring Verified

Status: VERIFIED UNDER REBUILT DOCKER DASHBOARD RUNTIME

Verified commits:

- 59d173fb Phase 717: activate lifecycle retry buttons

- 02abd4f1 Phase 717: wire lifecycle retry actions

- 44356f93 Phase 717: verify retry route after rebuild

- f7b6d929 Phase 717: record post-rebuild retry probe response

Verified UI artifact:

- public/js/phase530_visible_panels_bridge.js

Verified served JS markers:

- phase717RetryTask

- data-phase717-requeue

- data-phase717-retry-differently

- /api/delegate-task

Verified runtime route:

- POST /api/delegate-task

Verified retry payload contract:

{

  "kind": "retry",

  "strategy": "fresh-context",

  "title": "<operator action title>",

  "meta": {

    "retry_of_task_id": "<original_task_id>"

  },

  "source": "operator-guidance-ui"

}

Verified post-rebuild probe:

- task_id: t_c5767c3c-4974-480b-92b1-0d036c642718

- run_id: run_84768a04-db8d-4ea4-8d7e-01ecec3f3ab4

Operator-action guardrails:

- UI requires explicit click.

- UI requires browser confirmation.

- UI calls /api/delegate-task, not /api/tasks/create directly.

- Chat remains advisory-only and execution-isolated.

- No broad CSS/layout mutation was introduced.

- Renderer-scoped discipline preserved.

Next safe step:

- Perform browser-level manual click verification on a low-risk completed task card.

- Confirm new retry task appears in Recent Tasks.

- Confirm worker completes it.

- Preserve static execution evidence page as read-only audit surface.

