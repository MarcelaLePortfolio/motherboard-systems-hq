STATE HANDOFF — DO NOT LOSE CONTEXT

ASSISTANT OPERATES IN ENGINEERING CONTINUATION MODE

(Phase 462.4 — placement proof repair corridor opened,
oversized scan artifact neutralized, bounded evidence posture enforced)

────────────────────────────────

PHASE 462.4 — PLACEMENT PROOF REPAIR

CORRIDOR CLASSIFICATION:

EVIDENCE REPAIR / BOUNDARY HYGIENE

WHY THIS PHASE EXISTS

Previous placement proof produced an oversized artifact and included noisy scan behavior.

Observed issues:

• docs/phase462_3_accept_raw_input_placement_scan.txt was oversized
• scan included invalid directory target(s)
• evidence collection exceeded smallest-safe proof discipline

This phase restores evidence hygiene before any runtime mutation.

────────────────────────────────

REPAIR OBJECTIVE

Produce a bounded placement proof that:

• avoids invalid path targets
• limits scan output size
• identifies the smallest safe implementation file
• preserves single-boundary discipline

STRICTLY DISALLOWED:

• No runtime code edits
• No helper introduction
• No cross-layer mutation
• No implementation during repair

────────────────────────────────

REPAIR RULES

1. Scan only existing directories
2. Cap every search result set
3. Record only the most relevant anchors
4. Prefer smallest isolated file boundary
5. Do not proceed to implementation unless placement is clear

────────────────────────────────

EXPECTED OUTPUT

The repaired proof must identify:

• existing relevant type anchors
• existing intake/runtime candidate files
• safest single-file placement recommendation
• confirmation that implementation can remain intake-only

────────────────────────────────

NEXT SAFE MOVE

After repaired proof is captured:

• implement acceptRawInput in ONE file only
• test in isolation
• compare output against Phase 462.2 expectations

────────────────────────────────

STATE

STABLE
GUARDED
DETERMINISTIC
READY FOR BOUNDED PLACEMENT RE-PROOF

