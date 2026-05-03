CONTROLLED STABILITY + UX POLISH EXECUTION PLAN
(Post-Phase 528 — Deterministic Corridor)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OBJECTIVE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Stabilize runtime behavior, finalize event integrity confidence,
and enhance operator-facing UX without introducing backend risk.

STRICT CONSTRAINTS:
- NO backend mutations
- NO SQL changes
- NO pipeline changes
- UI / instrumentation only
- Single-scope iterations

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 1 — FIRST-CALL LATENCY ISOLATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Goal:
Identify root cause of first-call variability in Matilda.

Actions:
- Add timestamp logging at:
  • request received
  • Ollama call start
  • Ollama response received
  • response returned to UI

- Compare:
  • first call vs subsequent calls
  • container vs host timing (if needed)

Success Criteria:
- Clear identification of latency source:
  □ Ollama warmup
  □ network hop
  □ UI render delay

NO FIX applied in this step.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 2 — EVENT STREAM INTEGRITY (FINAL PASS)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Goal:
Confirm identity consistency across full lifecycle.

Validate:
- task.created
- task.running
- task.completed

Fields MUST match:
- task_id
- run_id
- attempts

Actions:
- Execute test task
- Inspect:
  • SSE stream
  • DB rows

Success Criteria:
- 100% identity consistency across all events
- No drift between emitted events and DB state

NO PATCH unless inconsistency is proven.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 3 — TASK HUMANIZATION (UI ONLY)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Goal:
Improve readability for operator.

Add:
- Human-readable task titles
- Friendly lifecycle labels:
  • "Queued"
  • "In Progress"
  • "Completed"

- Map raw event types → UI labels

Constraints:
- No backend schema changes
- No modification to event payloads

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 4 — TELEMETRY NARRATIVE LAYER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Goal:
Make event stream understandable as a story.

Transform UI display into:

1. Task received
2. Assigned to agent
3. Execution started
4. Execution completed

Enhancements:
- Order consistency
- Timestamp clarity
- Remove redundant noise

Constraints:
- UI-only transformation
- No event mutation

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 5 — MATILDA RESPONSE QUALITY PASS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Goal:
Improve clarity and usefulness of responses.

Enhance:
- Context summarization
- Task state awareness
- Response structure

DO NOT:
- Change reasoning engine
- Change fallback logic
- Modify API contract

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 6 — FINAL STABILITY CHECKPOINT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

After completion of Steps 1–5:

Verify:
- No regression in pipeline
- No change in execution behavior
- UI improvements stable

Then:
- Tag new checkpoint
- Document delta vs Phase 528

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 7 — COMPLIANCE WRAPPER PREP (DESIGN ONLY)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Goal:
Prepare Cade / Effie for external-safe builds.

Define:
- Boundary between:
  • internal Mirror constructs
  • external agent runtime

Ensure:
- External agents are:
  • self-contained
  • non-dependent on proprietary constructs

NO implementation in this phase.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EXECUTION DISCIPLINE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- One step at a time
- Validate before proceeding
- Max 3 attempts per issue
- Revert if ambiguity appears
- No speculative stacking of fixes

SYSTEM STATE:
STABLE · VERIFIED · CONTROLLED
