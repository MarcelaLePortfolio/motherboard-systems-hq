STATE HANDOFF — DO NOT LOSE CONTEXT

ASSISTANT OPERATES IN ENGINEERING CONTINUATION MODE

(Phase 464.3 — operator guidance tab re-entry proof corridor opened,
symptom classified as runtime duplication risk, evidence-only posture enforced)

────────────────────────────────

PHASE 464.3 — OPERATOR GUIDANCE TAB RE-ENTRY PROOF

CORRIDOR CLASSIFICATION:

RUNTIME SYMPTOM EVIDENCE COLLECTION

OBSERVED SYMPTOM

Operator guidance stream starts back up when:

• opening a new browser tab
• switching between browser tabs
• returning focus to the dashboard tab

RISK CLASS

Potential duplicate subscription / reinitialization / visibility-triggered replay

Possible causes include:

• duplicate stream initialization on mount/remount
• document visibility event re-trigger
• focus event re-trigger
• pageshow / lifecycle re-entry
• interval restart without teardown
• websocket / SSE reconnect without idempotent guard
• React effect re-run without stable cleanup

STRICTLY DISALLOWED:

• No runtime fix yet
• No speculative code mutation
• No multi-layer changes
• No fix-forward behavior

OBJECTIVE

Prove:

• where operator guidance stream is started
• whether tab visibility / focus / lifecycle events are wired
• whether duplicate initialization guards exist
• whether cleanup/unsubscribe behavior exists
• smallest safe mutation boundary for eventual fix

EXPECTED OUTPUT

This proof must produce:

• candidate operator guidance UI files
• stream initialization anchors
• tab lifecycle event anchors
• teardown / cleanup anchors
• likely smallest safe fix surface

NEXT SAFE MOVE

After evidence review:

• choose ONE smallest safe file boundary
• implement idempotent stream guard OR cleanup repair only
• verify symptom no longer reproduces

STATE

STABLE
GUARDED
DETERMINISTIC
READY FOR TAB RE-ENTRY EVIDENCE COLLECTION

