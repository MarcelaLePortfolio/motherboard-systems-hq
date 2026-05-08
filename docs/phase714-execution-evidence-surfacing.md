
# Phase 714 — Execution Evidence Surfacing

## Corridor

Execution Evidence & Operator Observability Corridor

## Goal

Improve surfaced operational evidence without changing execution authority, advisory boundaries, worker behavior, or chat isolation.

## Priority Order

1. Surface authoritative runtime evidence in the UI

2. Improve task event correlation visibility

3. Expose clearer failure lineage and retry history

4. Add concise operational evidence summaries

5. Preserve truthful, non-speculative wording

## Hard Constraints

- No hidden execution

- No silent task triggering

- No DB mutation from advisory chat

- No worker coupling from advisory chat

- No fabricated runtime state

- No speculative Matilda refinement

- No advisory scope creep

- Preserve Docker-authoritative validation

- Preserve Git-safe snapshot discipline

## Safe Starting Scope

Phase 714 should begin with a read-only evidence surface.

The first implementation should only summarize data that already exists from:

- tasks

- task_events

- run_view

- existing SSE streams

- existing inspector state

## Initial Implementation Target

Add a read-only operational evidence summary that shows:

- latest task lifecycle evidence

- latest task event timestamps

- worker claim/completion visibility

- retry attempt count when available

- failure lineage when present

- known vs unknown runtime evidence

## Wording Rules

Use truthful labels only:

- "Observed"

- "Last recorded"

- "No evidence available"

- "Awaiting next task event"

- "Unable to determine from current evidence"

Avoid unsupported labels:

- "healthy" unless directly evidenced

- "working" unless directly evidenced

- "failed because" unless cause is recorded

- "queue length" unless sourced from authoritative data

## Validation Requirements

After implementation, validate:

- dashboard loads on port 3000

- /api/tasks still responds

- /api/guidance still responds

- /api/chat still returns execution:false

- /api/chat still returns systemCoupling:false

- /events/task-events still streams

- worker execution path remains unchanged

## Rollback Rule

If the first implementation causes runtime ambiguity or build instability, revert immediately to Phase 713 and restart with a narrower read-only evidence-only patch.

