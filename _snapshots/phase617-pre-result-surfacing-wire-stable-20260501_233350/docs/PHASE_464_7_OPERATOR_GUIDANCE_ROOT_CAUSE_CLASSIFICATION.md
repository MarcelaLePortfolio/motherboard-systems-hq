STATE HANDOFF — DO NOT LOSE CONTEXT

ASSISTANT OPERATES IN ENGINEERING CONTINUATION MODE

(Phase 464.7 — operator guidance root-cause classification corridor opened,
single-file evidence digestion active, mutation still blocked until cause is explicit)

────────────────────────────────

PHASE 464.7 — OPERATOR GUIDANCE ROOT-CAUSE CLASSIFICATION

CORRIDOR CLASSIFICATION:

SINGLE-FILE ROOT-CAUSE DIGEST

PRIMARY OBJECTIVE:

Convert the selected-file inspection into an explicit root-cause decision:

• duplicate initialization
• missing cleanup
• lifecycle-triggered re-entry
• reconnect without dedupe
• interval restart without teardown

STRICTLY DISALLOWED:

• No runtime fix yet
• No speculative mutation
• No multi-file edits
• No fix-forward behavior

EXPECTED OUTPUT

This phase must produce:

• selected file path
• extracted effect / stream / lifecycle anchors with line numbers
• probable root-cause class
• exact next mutation type
• confirmation that the next edit remains ONE FILE ONLY

NEXT SAFE MOVE

Only after this classification is explicit:

• apply ONE bounded fix in the selected file only
• re-test tab open / tab switch reproduction

STATE

STABLE
GUARDED
DETERMINISTIC
READY FOR EXPLICIT ROOT-CAUSE CLASSIFICATION

