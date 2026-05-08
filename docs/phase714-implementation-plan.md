
# Phase 714 — Implementation Plan

## Current State

Phase 714 planning document committed successfully.

Verified:

- Git push succeeded

- Repo state synchronized

- No build mutations introduced yet

- Advisory boundary preserved

- Execution isolation preserved

## Immediate Next Safe Action

Perform a read-only inspection pass before modifying UI surfaces.

## Inspection Targets

1. Existing inspector UI components

2. Existing task evidence rendering

3. SSE subscription handlers

4. task_events consumption flow

5. run_view rendering path

6. retry metadata availability

7. current wording surfaces using unsupported certainty

## Required Constraints During Inspection

- NO runtime mutation

- NO execution pipeline edits

- NO worker lifecycle edits

- NO DB schema edits

- NO advisory chat edits

- NO speculative refactors

- NO cross-system cleanup

## First Patch Scope

Allowed:

- additive read-only UI evidence rendering

- evidence summary helpers

- wording corrections

- timestamp exposure

- retry visibility exposure

- failure lineage visibility

Not Allowed:

- execution orchestration changes

- scheduler activation

- automation logic

- retry policy mutation

- hidden polling systems

- inferred runtime certainty

## Required Evidence Language

Preferred:

- Observed

- Last recorded

- Awaiting next task event

- No evidence available

- Unable to determine from current evidence

Forbidden unless directly evidenced:

- healthy

- operational

- working correctly

- recovered

- stable

- failed because

## Validation Sequence After First Patch

1. npm install / dependency integrity unchanged

2. docker compose up -d --build succeeds

3. dashboard reachable on :3000

4. /api/tasks responds

5. /api/guidance responds

6. /api/chat returns:

   - execution:false

   - systemCoupling:false

7. /events/task-events streams

8. worker completes a real task

9. inspector reflects evidence without invented certainty

## Revert Rule

If:

- runtime ambiguity increases

- evidence wording becomes speculative

- SSE destabilizes

- inspector clarity regresses

- worker lifecycle changes unexpectedly

- build instability appears

Then:

- revert immediately to Phase 713 baseline

- reassess with narrower scope

- avoid layered fixes

