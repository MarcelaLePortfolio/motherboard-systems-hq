PHASE 62B — RUNNING TASKS EXECUTION PROTOCOL
Date: 2026-03-16

────────────────────────────────

PURPOSE

This protocol defines the exact bounded implementation posture for hydrating the Running Tasks tile.

This is the next execution layer after the deterministic plan.

It exists to prevent scope drift while enabling a narrow telemetry-only implementation.

────────────────────────────────

IMPLEMENTATION BOUNDARY

Allowed:

• Read existing task-events SSE wiring
• Extend existing telemetry derivation logic
• Add deterministic active-task tracking
• Add narrow reducer-safe tests
• Add replay and drift validation coverage if missing
• Bind hydrated value into existing tile only if tile already exists

Forbidden:

• New tiles
• Layout edits
• Styling changes
• Renaming IDs
• Database edits
• New API routes
• New authority paths
• Automation work
• Non-telemetry refactors
• Broad reducer rewrites

────────────────────────────────

REQUIRED EXECUTION ORDER

1. Locate current task-events ingestion path
2. Locate current telemetry reducer / derivation path
3. Locate existing Running Tasks tile binding
4. Implement deterministic active-task tracking
5. Add duplicate-event protection
6. Add terminal-wins handling
7. Verify replay behavior
8. Verify drift behavior
9. Verify no UI/layout mutation
10. Commit only if all checks pass

If any step implies broader refactor:
STOP
REVERT TO LAST STABLE CHECKPOINT
REDUCE SCOPE
REAPPLY NARROWLY

────────────────────────────────

DETERMINISTIC STATE MODEL

Maintain two bounded sets:

activeTaskIds
terminalTaskIds

Processing rules:

On task.created:
  if task_id not in terminalTaskIds
    add task_id to activeTaskIds

On task.started:
  if task_id not in terminalTaskIds
    add task_id to activeTaskIds

On task.running:
  if task_id not in terminalTaskIds
    add task_id to activeTaskIds

On task.completed:
  remove task_id from activeTaskIds
  add task_id to terminalTaskIds

On task.failed:
  remove task_id from activeTaskIds
  add task_id to terminalTaskIds

On task.cancelled:
  remove task_id from activeTaskIds
  add task_id to terminalTaskIds

Unknown events:
  ignore

Duplicate events:
  no net effect

Out-of-order terminal-first case:
  terminalTaskIds blocks later reactivation from historical non-terminal events

Derived metric:

runningTasks = size(activeTaskIds)

────────────────────────────────

REQUIRED INVARIANTS

The implementation must preserve all of the following:

• runningTasks >= 0 always
• runningTasks deterministic under replay
• terminal state always wins
• duplicate events do not inflate counts
• unknown events do not mutate counts
• historical late-arriving non-terminal events do not resurrect terminal tasks
• no mutation outside telemetry derivation boundary
• no behavioral change beyond metric hydration

────────────────────────────────

TEST CASES REQUIRED

Minimum required cases:

1. Simple lifecycle
   created -> started -> completed
   expected running: 1 -> 1 -> 0

2. Start without created
   started -> completed
   expected running: 1 -> 0

3. Terminal before start
   completed -> started
   expected running: 0 -> 0

4. Duplicate start
   started -> started -> completed
   expected running: 1 -> 1 -> 0

5. Duplicate terminal
   started -> completed -> completed
   expected running: 1 -> 0 -> 0

6. Failed lifecycle
   created -> failed
   expected running: 1 -> 0

7. Cancelled lifecycle
   created -> cancelled
   expected running: 1 -> 0

8. Unknown event ignored
   started -> task.unknown -> completed
   expected running: 1 -> 1 -> 0

9. Replay stability
   full stream replay twice
   expected same final value both times

10. Mixed multi-task replay
    overlapping tasks with terminal ordering
    expected deterministic final zero when all terminal

────────────────────────────────

VALIDATION GATE

Before commit, all of the following must be true:

• Layout contract passing
• Replay check passing
• Drift check passing
• Running Tasks tile hydrated
• No visual drift
• No telemetry warnings introduced
• No reducer regression introduced
• No authority expansion introduced

Recommended verification commands:

npm run telemetry:replay-check
npm run telemetry:drift-check
npm run layout:contract-check
npm test -- running-tasks

If the repo uses different command names, use equivalent existing project commands only.
Do not invent new command surfaces unless absolutely required for bounded validation.

────────────────────────────────

COMMIT STANDARD

This work should land only as:

A narrow telemetry hydration commit

Commit must not bundle:

• unrelated cleanup
• formatting-only churn
• other metric work
• automation preparation
• UI enhancements

One narrow hypothesis only.

────────────────────────────────

FAILURE PROTOCOL

If implementation causes any of the following:

• tile flicker
• replay mismatch
• layout drift
• reducer instability
• count resurrection after terminal state

Then:

1. Revert immediately to last stable checkpoint
2. Document exact failure mode
3. Reapply using smaller surface area

Never fix forward.

────────────────────────────────

SUCCESS CONDITION

Running Tasks is hydrated correctly from existing task-events telemetry.

The system remains:

• structurally stable
• telemetry-safe
• replay-safe
• drift-safe
• cognition-only
• behaviorally unchanged

