STATE HANDOFF — DO NOT LOSE CONTEXT

ASSISTANT OPERATES IN ENGINEERING CONTINUATION MODE

(Phase 462.7 — implementation site selection corridor opened,
ranked candidate decision resolved by bounded rule, no runtime mutation authorized)

────────────────────────────────

PHASE 462.7 — IMPLEMENTATION SITE SELECTION

CORRIDOR CLASSIFICATION:

SINGLE-FILE BOUNDARY SELECTION

PRIMARY OBJECTIVE:

Resolve the final implementation site for:

acceptRawInput(rawInput: string): OperatorRequest

using the bounded ranking already produced.

STRICTLY DISALLOWED:

• No runtime code edits
• No contract mutation
• No helper introduction
• No cross-layer wiring
• No multi-file preparation

────────────────────────────────

SELECTION RULE

The selected file MUST be:

• the first valid ranked candidate
• intake-safe
• narrower than any broader shared module
• free of governance / execution / approval / reporting responsibility

If no valid ranked candidate exists:

• STOP
• do not implement blindly
• preserve checkpoint discipline

────────────────────────────────

EXPECTED OUTPUT

This phase must produce:

• selected file path
• selection reason
• rejection reason for broader boundaries
• explicit confirmation that next mutation is ONE FILE ONLY

────────────────────────────────

NEXT SAFE MOVE

After selection is finalized:

• implement acceptRawInput in the selected file only
• runtime-test in isolation only
• compare against Phase 462.2 expectations only

────────────────────────────────

STATE

STABLE
GUARDED
DETERMINISTIC
READY FOR SINGLE-FILE IMPLEMENTATION SITE LOCK

