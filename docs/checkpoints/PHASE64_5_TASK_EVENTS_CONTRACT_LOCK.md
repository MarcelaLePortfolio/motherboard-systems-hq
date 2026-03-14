STATE CHECKPOINT — PHASE 64.5 TASK EVENTS CONTRACT LOCK
Date: 2026-03-14

────────────────────────────────

OBJECTIVE

Lock the Task Events corridor behind an explicit behavioral contract and an explicit enforcement contract.

This phase exists to prevent recurrence of:

- replay storms caused by cursor/query precision mismatch
- frozen Task Events UI caused by unhealthy endpoint behavior
- dashboard interactivity regressions caused by unsafe recovery patches
- repeated speculative fixes without first classifying the source of failure

This is a protection phase, not a feature phase.

────────────────────────────────

CONTRACT STATUS

Task Events corridor is now considered CONTRACT-GOVERNED.

Any future change affecting any of the following is inside the protected corridor:

- server/routes/task-events-sse.mjs
- dashboard Task Events rendering path
- Task Events tab mount behavior
- Task Events client-side replay handling
- any helper that changes Task Events stream semantics
- any CSS/JS change that could affect dashboard interactivity while Task Events is mounted

────────────────────────────────

TASK EVENTS BEHAVIOR CONTRACT

A healthy /events/task-events stream must satisfy all of the following:

1. FIRST CONNECT
   On initial connect the stream may emit:
   - hello

2. IDLE STATE
   When no new task events exist after the current cursor, the stream may emit:
   - heartbeat
   and no task.event replay storm

   Heartbeats-only is a valid healthy idle state.

3. REPLAY SAFETY
   The same task.event ID must not replay continuously on an idle connection.

4. CURSOR ADVANCE
   Cursor handling must advance deterministically from emitted event time without falling into precision mismatch loops.

5. DASHBOARD SAFETY
   Task Events must not block or stall dashboard load completion.
   Tabs must remain clickable.
   The Task Events tab must remain interactive.

6. FAILURE CLASSIFICATION
   Before any fix is attempted, the failure must be classified as one of:
   - endpoint replay / query / cursor issue
   - client mount / render issue
   - reconnection behavior issue
   - interactivity regression caused by unrelated patching

────────────────────────────────

TASK EVENTS ENFORCEMENT CONTRACT

The following are mandatory:

1. REQUIRED ENDPOINT GUARD
   After any /events/task-events change, run:
   bash scripts/_local/phase64_4_task_events_regression_guard.sh

2. REQUIRED DASHBOARD GUARD
   After any dashboard-side Task Events change:
   - open dashboard with cache-busting query param
   - hard refresh
   - verify dashboard completes load
   - verify tabs are clickable
   - verify Task Events tab remains interactive

3. NEVER PATCH FORWARD ON INTERACTIVITY FAILURE
   If dashboard interactivity breaks:
   - revert immediately to the last interactive baseline
   - do not continue stacking patches on broken UI

4. NO WRITER-LEVEL DEDUPE WITHOUT PROOF
   Do not add writer-level dedupe unless the precise duplication source is proven first.

5. ONE-HYPOTHESIS RULE
   Only one narrow Task Events hypothesis may be tested per push.

6. RESTORE-FIRST RULE
   If a Task Events experiment breaks page load, restore the last interactive baseline before any further debugging.

────────────────────────────────

ROUTINE PROTECTIVE MEASURES

These are now standard operating rules for the Task Events corridor:

- Contract doc must remain in repo
- Regression guard must remain in repo
- Convenience contract guard must remain in repo
- State handoff must mention the corridor is contract-governed
- Endpoint changes are incomplete until guard passes
- Dashboard Task Events changes are incomplete until interactivity is re-verified
- Replay storms must be diagnosed at source, never cosmetically hidden

────────────────────────────────

OPERATOR RESPONSE PLAYBOOK

When Task Events freezes or misbehaves:

1. Probe endpoint behavior first
2. Classify the failure source
3. Restore last interactive baseline if interactivity is affected
4. Apply one narrow fix only
5. Run regression guard
6. Re-verify dashboard interactivity
7. Commit only after both endpoint and UI checks are healthy

────────────────────────────────

CURRENT KNOWN GOOD UNDER THIS CONTRACT

Known healthy characteristics after cursor precision fix:

- /events/task-events no longer replays the same task.event ID endlessly in idle state
- idle stream can legitimately show hello + heartbeat only
- dashboard remains interactive
- Task Events stream resumes correctly once new events arrive

────────────────────────────────

DO NOT LOSE THIS RULE

Task Events is no longer an ad hoc debugging corridor.

It is now a protected contract corridor.
