STATE HANDOFF — DO NOT LOSE CONTEXT

ASSISTANT OPERATES IN ENGINEERING CONTINUATION MODE

(Phase 464.6 — selected fix surface inspection corridor opened,
single-file root-cause verification now active, no mutation yet authorized)

────────────────────────────────

PHASE 464.6 — OPERATOR GUIDANCE FIX SURFACE INSPECTION

CORRIDOR CLASSIFICATION:

SINGLE-FILE PRE-MUTATION ROOT-CAUSE VERIFICATION

PRIMARY OBJECTIVE:

Inspect the selected operator guidance fix target and prove:

• where stream initialization occurs
• whether lifecycle-triggered re-entry exists
• whether cleanup is present
• whether an idempotent guard is missing
• exact smallest safe mutation site inside the file

STRICTLY DISALLOWED:

• No fix yet
• No speculative edits
• No multi-file mutation
• No cross-layer changes

EXPECTED OUTPUT

This phase must produce:

• selected file path
• first 260 lines of file contents
• focused anchor scan for effect/stream/lifecycle/cleanup code
• explicit likely root-cause classification
• exact next mutation type:
  - add cleanup
  - add idempotent guard
  - both, if and only if same file boundary requires both

STATE

STABLE
GUARDED
DETERMINISTIC
READY FOR SINGLE-FILE ROOT-CAUSE VERIFICATION

