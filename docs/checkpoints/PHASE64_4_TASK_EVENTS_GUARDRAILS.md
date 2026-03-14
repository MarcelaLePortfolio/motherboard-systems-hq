STATE NOTE — PHASE 64.4 TASK EVENTS GUARDRAILS
Date: 2026-03-14

OBJECTIVE

Prevent future task-events regressions from reaching the dashboard UI.

ROOT LESSON

The freeze was caused by a server-side replay loop in /events/task-events.
The browser looked frozen because the UI was flooded by repeated copies of the same task.event.

GUARDRAILS

1. VERIFY THE STREAM BEFORE THE UI
   Always sample /events/task-events directly before debugging browser rendering.
   If the endpoint is replaying duplicate ids, the UI is downstream and should not be patched first.

2. TREAT THESE AS SEPARATE HYPOTHESES
   - endpoint replay logic
   - cursor progression logic
   - UI mount / visibility logic
   - CSS sizing logic

   Never mix these into one patch.

3. NEVER PATCH FORWARD WHEN INTERACTIVITY BREAKS
   If the dashboard stops finishing load or tabs stop responding:
   revert immediately to the last interactive baseline before continuing.

4. HEARTBEATS-ONLY IS A VALID IDLE STATE
   If the cursor starts at the latest event, an idle stream should show:
   - hello
   - heartbeat
   and no task.event spam

   That is healthy.

5. REQUIRED CHECK AFTER ANY /events/task-events CHANGE
   Run:
   bash scripts/_local/phase64_4_task_events_regression_guard.sh

   The change is not complete until this passes.

6. REQUIRED CHECK AFTER ANY DASHBOARD TASK EVENTS CHANGE
   Open the dashboard with a cache-busting query param.
   Hard refresh.
   Confirm:
   - dashboard finishes loading
   - tabs are clickable
   - Task Events tab remains interactive
   - no replay storm appears in the endpoint guard

7. DO NOT DEDUPE BLINDLY IN THE WRITER
   Writer-level dedupe is high risk unless the exact replay source is proven.
   First prove whether duplication originates from:
   - cursor math
   - query predicate
   - route loop behavior
   - client reconnection behavior

OPERATOR RULE

When Task Events freezes:
1. probe endpoint
2. classify source
3. restore baseline if interactivity is affected
4. apply one narrow fix
5. run regression guard
