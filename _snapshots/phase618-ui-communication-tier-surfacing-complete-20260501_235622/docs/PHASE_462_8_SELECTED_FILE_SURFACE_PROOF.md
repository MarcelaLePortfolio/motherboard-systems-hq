STATE HANDOFF — DO NOT LOSE CONTEXT

ASSISTANT OPERATES IN ENGINEERING CONTINUATION MODE

(Phase 462.8 — selected file surface proof corridor opened,
pre-mutation file-boundary verification required, deterministic proof posture enforced)

────────────────────────────────

PHASE 462.8 — SELECTED FILE SURFACE PROOF

CORRIDOR CLASSIFICATION:

PRE-MUTATION FILE BOUNDARY VERIFICATION

PRIMARY OBJECTIVE:

Inspect the locked implementation site for:

acceptRawInput(rawInput: string): OperatorRequest

before any runtime mutation occurs.

STRICTLY DISALLOWED:

• No runtime code edits
• No helper introduction
• No contract mutation
• No cross-layer wiring
• No multi-file preparation

────────────────────────────────

WHY THIS PHASE EXISTS

A file path has been selected.

Before replacing or appending any code, we must prove:

• what the selected file currently contains
• whether it is intake-only or mixed-responsibility
• whether a full-file replacement would be safe
• whether implementation must stop due to boundary contamination

This preserves:

• smallest-safe-change discipline
• single-boundary mutation discipline
• rollback clarity

────────────────────────────────

REQUIRED QUESTIONS

1. Does the selected file already exist?
2. If it exists, is it intake-only?
3. Does it contain governance/execution/approval/reporting logic?
4. Would mutating it violate single-boundary discipline?
5. Is full-file replacement safe, or must mutation stop?

────────────────────────────────

EXPECTED OUTPUT

This proof must produce:

• selected file path
• existence status
• first 250 lines of current contents (bounded)
• grep-based responsibility scan
• explicit go / no-go decision for single-file mutation

────────────────────────────────

DECISION RULE

Implementation may proceed ONLY if ALL are true:

• selected file is intake-only
• no governance/execution/approval/reporting responsibility exists
• file mutation remains single-boundary
• runtime mutation can occur without touching any other file

Otherwise:

• STOP
• do not implement blindly
• preserve checkpoint discipline

────────────────────────────────

NEXT SAFE MOVE

If GO:

• implement acceptRawInput in the selected file only
• runtime-test in isolation only

If NO-GO:

• stop
• reassess placement
• do not mutate runtime surfaces

────────────────────────────────

STATE

STABLE
GUARDED
DETERMINISTIC
READY FOR FILE SURFACE VERIFICATION

