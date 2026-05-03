# Phase 37.4 — Terminal Event Integrity Gaps (Planning Only)

## Problem Statement
Acceptance lens reports **5 runs** where `run_view.is_terminal = true` while `terminal_event_kind/ts/id` are NULL.
This means: the system believes the run is terminal, but **no terminal task_events row is being surfaced as the terminal**.

Evidence captured:
- `artifacts/phase37_3_integrity_gaps_20260211_130102/acceptance.out`
- Per-run snapshots in that same folder.

## What the forensics show (initial read)
For each of the 5 run_ids:
- `run_view.last_event_kind` is `task.completed`
- `task_events` *does* include `task.completed` for the run_id
- Yet `run_view.terminal_event_*` is NULL

This suggests the gap is not "missing terminal event rows" but rather:
- terminal derivation logic isn't selecting them as terminal for these runs, OR
- terminal mapping expects a different kind set than what's present, OR
- join/filter conditions prevent terminal selection for a subset of rows (e.g. actor/task_id matching, canonicalization, etc.)

## Hypotheses (ordered)
H1) **Kind mismatch in terminal selector**:
`run_view.terminal_event_*` selection logic filters on kinds that exclude `task.completed` (or uses different naming/casing).
- Would explain: last_event sees `task.completed` but terminal selector returns NULL.

H2) **Terminal selector uses tasks.status rather than event kinds** and expects terminal events to be from a narrower set.
- But we still see `task.completed` in task_events, so why excluded?

H3) **Terminal selector requires additional predicates** (e.g., matching `task_id`, `run_id`, `actor`, or a canonical “terminal” provenance) that these rows fail.
- Example: terminal selection uses a projection rule that prefers only “canonical” terminal rows or requires a specific actor class.

H4) **Data anomaly in task_events**:
The `task.completed` rows exist but violate invariants used by the selector (e.g., NULL task_id, unexpected actor format, duplicated event id, etc.).
- Needs targeted inspection against run_view definition.

## Plan: decision-ready checks (still planning-only)
1) Inspect `PHASE37_RUN_VIEW_DEFINITION.sql` and identify exactly how `terminal_event_*` is computed.
2) For each run in the artifacts bundle:
   - Compare the `task_events` terminal row fields against the selector predicates.
3) Produce a single-page decision record:
   - Root cause (exact predicate/kind mismatch)
   - Minimal change options ranked by safety (acceptance-only vs view change vs worker change)
   - Expected blast radius + rollback plan

## Non-goals (hard)
- No schema changes
- No run_view changes
- No worker changes
- No backfills
This phase ends with a **decision record + proposed next phase scope**, not implementation.

## Deliverable
- `PHASE37_4_DECISION_RECORD.md` (filled) + pointer to specific lines in run_view definition responsible.
