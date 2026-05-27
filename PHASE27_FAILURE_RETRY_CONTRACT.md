Phase 27 — Task Worker Failure + Retry Semantics (Contract)

Objective
- Define deterministic failure + retry semantics for the task worker, backed by Postgres.

Fields (tasks table)
- attempt (int): increments on every successful claim.
- max_attempts (int): cap after which task becomes terminal failed.
- available_at (timestamptz): not claimable until now() >= available_at.
- locked_by (text): worker id holding the lease.
- lock_expires_at (timestamptz): lease expiry; reclaim allowed after expiry.
- last_error (jsonb): most recent failure payload.

States
- queued: eligible to claim (subject to available_at + lease rules)
- running: claimed and leased by a worker
- completed: terminal success
- failed: terminal failure

Eligibility
A task is claimable when:
- status = 'queued'
- AND (available_at IS NULL OR available_at <= now())
- AND (lock_expires_at IS NULL OR lock_expires_at < now())

Orphan reclaim (optional but recommended)
- A task in 'running' may be reclaimed if lock_expires_at IS NOT NULL AND lock_expires_at < now().
- Reclaim MUST be atomic and MUST bump attempt (same as normal claim).

Atomic claim (single statement / transaction)
On claim, atomically:
- status = 'running'
- attempt = attempt + 1
- locked_by = <worker_id>
- lock_expires_at = now() + TASK_LOCK_MS
- started_at = COALESCE(started_at, now())  (optional)
Emit task_events:
- kind: task.running
- payload: { ts, task_id, run_id, actor, attempt, max_attempts }

Success
On success:
- status = 'completed'
- completed_at = now()
- locked_by = NULL
- lock_expires_at = NULL
Emit:
- task.completed { ts, task_id, run_id, actor, attempt }

Failure + retry
On exception, build last_error:
{ ts, message, code?, stack?, attempt, max_attempts, terminal, backoff_ms?, next_available_at? }

If attempt < max_attempts:
- compute backoff_ms = min(cap, base * 2^(attempt-1)) with jitter ±30%
- status = 'queued'
- available_at = now() + backoff_ms
- last_error = <json terminal:false ...>
- locked_by = NULL
- lock_expires_at = NULL
Emit:
- task.failed   { ts, task_id, run_id, actor, attempt, max_attempts, terminal:false, backoff_ms, error:{message,code?} }
- task.requeued { ts, task_id, run_id, actor, attempt, max_attempts, available_at }

If attempt >= max_attempts:
- status = 'failed'
- last_error = <json terminal:true ...>
- locked_by = NULL
- lock_expires_at = NULL
Emit:
- task.failed { ts, task_id, run_id, actor, attempt, max_attempts, terminal:true, error:{message,code?} }

Backoff knobs (defaults)
- TASK_LOCK_MS=60000
- TASK_MAX_ATTEMPTS=5
- TASK_RETRY_BASE_MS=1500
- TASK_RETRY_CAP_MS=60000
