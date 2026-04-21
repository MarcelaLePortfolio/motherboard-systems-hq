PHASE 487 — CORRIDOR SELECTION RECORD

Generated: $(date)

────────────────────────────────

SELECTION

C — MATILDA COGNITION CORRIDOR

Intent:
Upgrade Matilda from placeholder → deterministic, state-aware assistant using existing read surfaces only.

────────────────────────────────

SCOPE LOCK

ALLOWED:

• Read from existing endpoints:
  - /api/tasks
  - /diagnostics/system-health
  - /api/guidance (if present)
• Deterministic response composition
• Context stitching (no mutation)
• UI consumption only

STRICTLY FORBIDDEN:

✖ Any governance changes
✖ Any approval system changes
✖ Any execution pipeline changes
✖ Any new backend routes
✖ Any async/non-deterministic behavior
✖ Any hidden state or memory

────────────────────────────────

GOAL

Matilda should:

• Acknowledge user input
• Reference current system state
• Reference recent tasks (if present)
• Provide clear, bounded, human-readable responses

WITHOUT:

• hallucination
• speculation
• hidden reasoning
• side effects

────────────────────────────────

SUCCESS CRITERIA

✔ Response includes:
  - user message acknowledgment
  - system health summary
  - task context (if available)

✔ Fully deterministic
✔ No backend mutation
✔ No regression of existing surfaces

────────────────────────────────

ENTRY POINT

Modify ONLY:

server route:
→ /api/chat

Replace placeholder logic with deterministic state-aware composition.

────────────────────────────────

FAILURE CONDITION

If ANY of the following occur:

• unclear response logic
• need for new data source
• temptation to add backend capability

→ STOP
→ REVERT TO CHECKPOINT
→ REASSESS

────────────────────────────────

STATE TRANSITION

FROM:
PLACEHOLDER-ONLY

TO:
DETERMINISTIC-STATE-AWARE (READ-ONLY)

────────────────────────────────

APPROVED

CORRIDOR OPEN
