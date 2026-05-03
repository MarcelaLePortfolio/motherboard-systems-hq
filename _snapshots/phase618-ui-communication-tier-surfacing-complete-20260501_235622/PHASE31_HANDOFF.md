Phase 31 — Smoke script payload/meta compatibility (current state)

Branch:
- feature/phase31-smoke-payload-compat

Checkpoint tag:
- v31.0-phase31-smoke-payload-compat-ok

What changed:
- scripts/phase28_smoke_one.sh now auto-detects whether tasks.payload exists.
  - If tasks.payload exists: seeds failing task into tasks.payload (jsonb)
  - Else: seeds into tasks.meta (jsonb)
- Smoke remains deterministic:
  - Pins claim SQL to the seeded TASK_ID so other queued tasks cannot steal the claim.
- Expected result:
  - After one worker claim, the task has attempt=1, last_error set, and available_at set for retry (unless terminal).
  - task_events includes task.running + task.failed (+ task.retry_scheduled) with task_id persisted as text.

How to verify:
- POSTGRES_URL=... ./scripts/phase28_smoke_one.sh
