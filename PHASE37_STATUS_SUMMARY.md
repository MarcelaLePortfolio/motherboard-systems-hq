# Phase 37 — Status Summary (Planning Ladder)

## Protocols (Phase 37 planning ladder)
- Planning-only unless explicitly promoted.
- No schema changes.
- No view edits.
- No worker changes.
- Canonical ordering for “latest” semantics: `task_events.ts` ASC, tie-breaker `task_events.id` ASC.

---

## Phase 37.0 — last_event provenance ✅
- Deliverable:
  - `PHASE37_RUN_VIEW_PROVENANCE_MATRIX.md` filled for:
    - `last_event_id`
    - `last_event_ts`
    - `last_event_kind`
- Validation:
  - Acceptance lens §2a returns **0 mismatches** (last_event fields match max `(ts,id)` per `run_id`).
- Frozen baseline:
  - `v37.0-phase37-planning-last_event_provenance`

---

## Phase 37.1 — terminal provenance + mismatch captured ✅
- Deliverables:
  - `PHASE37_1_TERMINAL_EVENT_PROVENANCE.md` (mechanical provenance for `terminal_event_{kind,ts,id}` + `is_terminal`)
  - `PHASE37_1_HANDOFF_ONELINER.txt`
- Key finding (no implementation yet):
  - Acceptance lens uses `task.*` terminal kinds, but `run_view` uses bare terminal kinds.
- Frozen baseline (true stop-state):
  - `v37.1-phase37-planning-terminal_provenance-stop`

---

## Phase 37.2 — alignment options enumerated ✅
- Deliverables:
  - `PHASE37_2_ALIGNMENT_OPTIONS.md` (Options A/B/C for kind namespace + notes on “latest” rule mismatch)
  - `PHASE37_2_HANDOFF_ONELINER.txt`
- Frozen baseline (true stop-state):
  - `v37.2-phase37-planning-terminal_kind_alignment_options-stop`

---

## Next decision gate (before Phase 37.3 implementation)
Choose one terminal-kind alignment strategy:

- Option A: Acceptance lens matches current `run_view` (bare kinds)
- Option B: `run_view` matches acceptance lens (`task.*` kinds) — requires view edit later
- Option C: Dual-accept during migration — tolerates mixed history

Also decide: contract “latest terminal event” rule:
- Canonical `(ts,id)` (preferred, consistent with Phase 37 ordering rule), vs
- View’s current latest-by-id selection within `(task_id, run_id)`.

No implementation should begin until both decisions are explicitly selected.

