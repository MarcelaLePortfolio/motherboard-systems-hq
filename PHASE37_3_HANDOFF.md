# Phase 37.3 — DONE (Acceptance lens terminal kinds aligned)

## Shipped
- Acceptance lens §4a + §4b terminal kinds aligned to authoritative run_view bare kinds
- Rerun clears false terminal_mismatch (0 rows)

## Remaining signal
- Any remaining §4b rows indicate integrity gaps:
  tasks.status is terminal but there is no terminal task_events row

## Baseline tag
- v37.3-phase37-acceptance-terminal_kinds-aligned

## Protocol boundary
- No schema/view/worker changes beyond acceptance SQL
- Stop here
