# Phase 25 — Deterministic Fold Function (Spec)

Purpose:
- Provide ONE deterministic way to compute task lifecycle state from persisted `task_events`.
- All consumers (API, SSE, UI, orchestration) must reference this fold (directly or indirectly).

## Inputs

An ordered stream of persisted events for a single `task_id`:
- Source: `task_events` table
- Ordering: ascending by `(cursor | ts | insertion order)` — MUST be deterministic.
- Input event shape (minimum):
  - `kind`: string (e.g. "task.created", "task.progress", "task.completed", "task.failed", "task.canceled")
  - `payload`: JSON containing at least `task_id` and optional `run_id`, `status`, `error`, `meta`

## Output

A canonical state object:
- `task_id: string`
- `state: "NEW" | "QUEUED" | "RUNNING" | "COMPLETED" | "FAILED" | "CANCELED"`
- `terminal: boolean`
- `run_id?: string`
- `attempts?: number`
- `last_error?: string`
- `last_event_kind?: string`
- `last_event_ts?: number`
- `history_cursor_max?: number`

## Allowed transitions (state machine)

- NEW -> QUEUED (on "task.created" or "task.queued")
- QUEUED -> RUNNING (on "task.started" or "task.progress" with running/started)
- RUNNING -> COMPLETED (on "task.completed")
- RUNNING -> FAILED (on "task.failed")
- QUEUED -> CANCELED (on "task.canceled")
- RUNNING -> CANCELED (on "task.canceled")

Terminal states:
- COMPLETED, FAILED, CANCELED

Terminal invariants:
1) Once terminal, additional lifecycle events are REJECTED by the writer (preferred) OR ignored by fold (fallback).
2) Fold MUST be deterministic regardless of duplicated / replayed SSE frames.
3) Fold MUST be idempotent given the same ordered input events.

## Deduplication (writer responsibility)

Semantic dedupe key (recommended):
- `(kind, task_id, run_id, payload_hash)` within a short window
- Heartbeats must NOT affect lifecycle.

## Non-lifecycle events

Kinds not in the lifecycle set (e.g. "heartbeat", "hello", "log.*", "task.event" generic) MUST NOT change lifecycle state.

## Authority rules

- Only `task_events` defines lifecycle.
- UI must never infer lifecycle from status strings or connection state.
- SSE disconnects never imply lifecycle changes.

