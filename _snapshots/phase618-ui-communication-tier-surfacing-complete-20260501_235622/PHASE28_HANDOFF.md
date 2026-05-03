Phase 28 — Failure routing + deterministic smoke (current state)

Branch:
- feature/phase28-failure-routing-smoke

Checkpoint tag:
- v28.1-phase28-smoke-deterministic-ok

What works:
- Worker claims tasks using current DB schema fields (tasks.available_at, attempt, meta; locks via locked_by/lock_expires_at).
- execTask throw routes into handleFailure:
  - emits task.failed (task_events.task_id persisted as text)
  - updates tasks.last_error (jsonb)
  - schedules retry via available_at/next_run_at using exponential backoff (base/max envs)
  - emits task.retry_scheduled
- Smoke script is deterministic: pins claim to the seeded TASK_ID so retries/other queued tasks don't steal the claim.

Key files:
- server/worker/phase26_task_worker.mjs
- server/worker/phase28_claim_one.sql
- server/worker/phase28_mark_success.sql
- server/worker/phase28_mark_failure.sql
- scripts/phase28_smoke_one.sh

How to verify:
- POSTGRES_URL=... ./scripts/phase28_smoke_one.sh
- Expect OK; task ends queued with attempt=1 and future available_at; task_events includes task.running, task.failed, task.retry_scheduled.
