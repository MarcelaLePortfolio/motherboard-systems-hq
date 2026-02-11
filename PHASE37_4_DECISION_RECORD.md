# Phase 37.4 — Decision Record: Terminal Event Integrity Gaps

## Context
Acceptance lens shows 5 runs where `run_view.is_terminal = true` but `terminal_event_*` is NULL.
Artifacts: `artifacts/phase37_3_integrity_gaps_20260211_130102/`

## Observed Facts (from forensics)
- [ ] For each run, list `last_event_kind`, `terminal_event_kind`, and whether a `task.completed`/`task.failed` row exists in `task_events`.

## Root Cause (exact)
- [ ] Point to the exact predicate / kind-set / join in `PHASE37_RUN_VIEW_DEFINITION.sql` that excludes these rows (include line numbers).

## Options
### Option A — Acceptance-only patch (if possible)
- Change:
- Why safe:
- Limitations:

### Option B — run_view adjustment (next phase, if needed)
- Change:
- Why safe:
- Rollback:

### Option C — Worker emission correction (next phase, if needed)
- Change:
- Why safe:
- Rollback:

## Decision
- [ ] Chosen option:
- [ ] Rationale:
- [ ] Next phase scope:

## Protocol Notes
No implementation in Phase 37.4. This document gates any schema/view/worker changes in the next phase.
