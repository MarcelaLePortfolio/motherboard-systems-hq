# PR 84 — run_view terminal precedence

## Problem
A task can emit post-terminal noise (e.g., `task.running`) after a terminal event exists.
If run observability derives `task_status` / `is_terminal` from the mutable `tasks.status` alone,
a completed run can appear to “regress” to non-terminal.

## Fix
In `run_view`, once a `terminal_event` exists for `(task_id, run_id)`, it becomes authoritative:
- `task_status` derives from `terminal_event_kind` when present
- `is_terminal` is `TRUE` when `terminal_event_kind` is present

## Why this is safe
- Terminal events are selected deterministically by `(task_id, run_id, id DESC)`
- This prevents late/non-causal events from changing terminal truth
- Consumers still receive `last_event_*` fields for observability/debugging

## Files
- `drizzle_pg/0007_phase36_1_run_view.sql`

## Verification
- CI: build-and-test + Phase 54 regression harness
- Local: compose up; query `run_view` for runs that have `terminal_event_kind` and confirm `is_terminal=TRUE`
