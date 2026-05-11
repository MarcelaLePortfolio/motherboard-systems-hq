
PHASE 718 LINEAGE RENDER PATCH PLAN

Authoritative renderer target:

- public/js/phase530_visible_panels_bridge.js

Verified live fields:

- explanation_preview

- strategy

- retry_of_task_id

Verified live controls:

- Requeue

- Retry differently

Safe next implementation:

1. Add read-only "Execution Strategy" label to lifecycle cards.

2. Add read-only "Retry Of" label when retry_of_task_id exists.

3. Reuse existing task metadata only.

4. Do NOT add backend calls.

5. Do NOT redesign retry semantics.

6. Do NOT modify SSE contracts.

7. Do NOT modify DB schema.

8. Keep patch renderer-scoped only.

