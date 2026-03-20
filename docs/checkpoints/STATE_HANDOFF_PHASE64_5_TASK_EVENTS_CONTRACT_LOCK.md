STATE HANDOFF — DO NOT LOSE CONTEXT
Phase 64.4 Task Events Recovery → Phase 64.5 Task Events Contract Lock
Date: 2026-03-14

────────────────────────────────

CURRENT OBJECTIVE

Phase 64.4 endpoint recovery is COMPLETE.

The Task Events stream was restored by fixing cursor precision mismatch in the SSE route, which eliminated the replay storm of identical task.event IDs and returned the stream to healthy idle behavior.

Phase 64.5 now establishes a formal contract lock around the Task Events corridor.

Immediate development posture:

SAFE REST STATE.

Task Events is working again.
Dashboard interactivity is restored.
Future work in this corridor must follow contract rules.

────────────────────────────────

WHAT WAS PROVEN

The freeze was not just a cosmetic dashboard issue.

The actual failure source was endpoint replay behavior:
- the Task Events SSE stream continuously replayed the same event ID
- this created a pathological stream state
- dashboard behavior degraded as a downstream symptom

The successful fix was:
- cursor precision correction in server/routes/task-events-sse.mjs

Healthy idle behavior is now:
- hello
- heartbeat
with no replay storm

That is valid.

────────────────────────────────

CRITICAL RULE — NEVER FIX FORWARD

If Task Events or dashboard interactivity breaks again:

DO NOT patch forward on broken interactivity
DO NOT stack speculative fixes
DO NOT add blind dedupe at writer level
DO NOT continue after page-load regression

Instead:

1. Probe /events/task-events
2. Classify the failure source
3. Restore last interactive baseline if interactivity is affected
4. Apply one narrow fix
5. Run the regression guard
6. Re-verify dashboard interactivity

Marcela protocol applies here fully:
broken interactivity is restored first, not debugged in-place.

────────────────────────────────

CONTRACT STATUS

The Task Events corridor is now CONTRACT-GOVERNED.

Protected surfaces include:
- server/routes/task-events-sse.mjs
- dashboard Task Events mount/render path
- Task Events tab behavior
- any helper affecting stream semantics
- any patch that could impact dashboard interactivity while Task Events is active

Mandatory guard after any endpoint change:
bash scripts/_local/phase64_4_task_events_regression_guard.sh

Mandatory follow-up after any dashboard Task Events change:
- open cache-busted dashboard
- hard refresh
- verify page finishes load
- verify tabs are clickable
- verify Task Events tab remains interactive

────────────────────────────────

CURRENT KNOWN GOOD BASELINE

Branch:
phase63-telemetry-enrichment

Task Events endpoint currently reaches healthy idle state:
- hello
- heartbeat only
- no identical task.event replay storm

Dashboard:
- loads successfully
- remains interactive
- Task Events stream no longer fails due to replay storm

────────────────────────────────

NEXT SAFE WORK

Any future Task Events work should now be treated as a narrow protected subphase only.

Priority order for future work:
1. preserve endpoint health
2. preserve dashboard interactivity
3. only then improve visual polish or telemetry ergonomics

No speculative rewrite work should happen in this corridor without restoring from a known interactive baseline if anything breaks.
