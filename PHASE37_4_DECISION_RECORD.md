# Phase 37.4 — Decision Record: Terminal Event Integrity Gaps

## Context
Acceptance lens shows 5 runs where `run_view.is_terminal = true` but `run_view.terminal_event_*` is NULL.
Artifacts: `artifacts/phase37_3_integrity_gaps_20260211_130102/`

## Observed Facts (from forensics)
For each of the 5 run_ids in `artifacts/.../run_ids.txt`:
- `run_view.last_event_kind = 'task.completed'`
- `task_events` contains a terminal-ish row with `kind = 'task.completed'` for the same `(task_id, run_id)`
- Yet `run_view.terminal_event_kind/ts/id` are NULL

## Root Cause (exact)
**Kind-set mismatch in `PHASE37_RUN_VIEW_DEFINITION.sql` terminal selector.**

- `terminal_event` CTE filters `task_events.kind` to **bare kinds**:
  - `ARRAY['completed','failed','canceled','cancelled']`
- But actual terminal event rows use **prefixed kinds**:
  - `task.completed` (and likely `task.failed`, etc.)

Therefore:
- `last_event` (no kind filter) correctly sees `task.completed`
- `terminal_event` (bare-kind filter) returns no rows → `terminal_event_*` NULL

### Evidence (line numbers)
From `PHASE37_RUN_VIEW_DEFINITION.sql`:
- `terminal_event` CTE kind filter at **L41-L42**:
  - `WHERE ... te_1.kind = ANY (ARRAY['completed','failed','canceled','cancelled'])`
- `last_event_kind` comes directly from `task_events.kind` at **L21-L23** (no filter).
- `is_terminal` is derived from `tasks.status` at **L64-L66** (independent of event kind).

## Options (ranked by safety / contract alignment)
### Option A — Acceptance-only patch (NOT sufficient here)
- Change: acceptance SQL could detect/report this mismatch, but cannot make `run_view.terminal_event_*` non-NULL without changing the view logic.
- Why safe: acceptance-only.
- Limitation: does not repair the projection; only improves reporting.

### Option B — run_view adjustment (recommended next implementation phase)
- Change: update `terminal_event` CTE to match the authoritative kind namespace actually emitted:
  - include `task.completed`, `task.failed`, `task.canceled`, `task.cancelled` (and optionally `task.timeout` / `task.timed_out` if those exist)
  - OR normalize kinds (strip `task.` prefix) consistently for both `last_event_kind` and `terminal_event_kind`
- Why safe:
  - projection-only change; no schema mutation
  - aligns terminal selection to real `task_events` data
  - fixes `terminal_event_*` being NULL while preserving `last_event_*` semantics
- Rollback:
  - revert the view definition commit (phase-scoped) to restore prior behavior

### Option C — Worker emission correction (deprioritized)
- Change: make workers emit bare kinds instead of `task.*`.
- Why safe: could align to current view filter.
- Risk: higher blast radius (behavioral change), backward compatibility, and not warranted since the platform already uses `task.*` kinds broadly.

## Decision
- Chosen option: **Option B (run_view adjustment)**
- Rationale:
  - The forensics prove terminal rows exist; selection predicate is wrong.
  - Acceptance-only cannot correct `run_view.terminal_event_*`.
  - Worker change is unnecessary and higher-risk.
- Next phase scope (Phase 37.5 — Implementation):
  - Patch `PHASE37_RUN_VIEW_DEFINITION.sql` `terminal_event` CTE to include `task.*` terminal kinds (and any known timeout variant if present).
  - Re-run `PHASE37_ACCEPTANCE_CHECKS.sql` to confirm the 5-run gap clears.
  - Keep changes projection-only (no schema, no worker).

## Protocol Notes
No implementation in Phase 37.4. This decision record gates any schema/view/worker changes in the next phase.
