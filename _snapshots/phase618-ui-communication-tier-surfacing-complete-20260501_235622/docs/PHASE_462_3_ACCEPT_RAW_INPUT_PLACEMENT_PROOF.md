STATE HANDOFF — DO NOT LOSE CONTEXT

ASSISTANT OPERATES IN ENGINEERING CONTINUATION MODE

(Phase 462.3 — acceptRawInput placement proof corridor opened,
pre-mutation placement verification required, deterministic proof posture enforced)

────────────────────────────────

PHASE 462.3 — acceptRawInput PLACEMENT PROOF

CORRIDOR CLASSIFICATION:

PRE-IMPLEMENTATION TOPOLOGY VERIFICATION

TARGET:

Locate the correct implementation surface for:

acceptRawInput(rawInput: string): OperatorRequest

without introducing mutation.

STRICTLY DISALLOWED:

• No runtime code edits
• No helper introduction
• No interface expansion
• No cross-layer wiring
• No contract mutation

────────────────────────────────

OBJECTIVE

Before implementing the first runtime function, prove:

• where the IntakeInterface belongs
• whether an intake/runtime surface already exists
• whether OperatorRequest is already defined
• whether a safe local implementation file already exists
• whether implementation can occur without touching other layers

This phase is EVIDENCE ONLY.

────────────────────────────────

REQUIRED QUESTIONS

1. Is there already an intake-related module?
2. Is there already an OperatorRequest type or equivalent?
3. Is there already a runtime-safe pure utility/module location?
4. Can acceptRawInput be added without modifying governance/execution code?
5. What is the smallest safe file boundary for implementation?

────────────────────────────────

EXPECTED OUTPUT

This proof must produce:

• candidate file paths
• existing related type definitions
• existing interface/module anchors
• recommended single-file placement
• confirmation that no multi-layer edit is required

────────────────────────────────

MUTATION RULE

If placement is ambiguous:

• STOP
• do not implement blindly
• preserve checkpoint discipline
• choose smallest safe boundary only after proof

────────────────────────────────

NEXT STEP

After this placement proof is generated:

• implement acceptRawInput in ONE file only
• test it in isolation
• compare actual output against Phase 462.2 expectations

────────────────────────────────

STATE

STABLE
GUARDED
DETERMINISTIC
READY FOR PLACEMENT VERIFICATION

