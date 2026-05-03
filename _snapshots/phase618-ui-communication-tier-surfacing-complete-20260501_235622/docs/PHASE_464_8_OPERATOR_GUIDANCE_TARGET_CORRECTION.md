STATE HANDOFF — DO NOT LOSE CONTEXT

ASSISTANT OPERATES IN ENGINEERING CONTINUATION MODE

(Phase 464.8 — operator guidance target correction corridor opened,
previous fix target misclassified, actual browser guidance surfaces now isolated)

────────────────────────────────

PHASE 464.8 — OPERATOR GUIDANCE TARGET CORRECTION

CORRIDOR CLASSIFICATION:

FIX-BOUNDARY CORRECTION / REAL UI SURFACE ISOLATION

WHY THIS PHASE EXISTS

Previous single-file target selection was wrong.

Misclassified target:
• scripts/operator-runbook-assert.ts

That file is not a browser operator-guidance stream surface.
It is not the correct place to repair a tab-switch guidance flood.

The real symptom exists in browser-facing dashboard code.

────────────────────────────────

ACTUAL TARGET CLASS

Correct search surface must now be restricted to:

• public/dashboard.html
• public/js/operatorGuidance.sse.js
• public/js/phase457_restore_task_panels.js
• public/js/phase457_neutralize_legacy_observational_consumers.js
• bundle.js if and only if operator-guidance anchors resolve there

────────────────────────────────

OBJECTIVE

Prove which ACTUAL browser file is responsible for:

• operator guidance rendering
• duplicate stream/start behavior
• lifecycle-triggered replay
• append/flood behavior

STRICTLY DISALLOWED:

• No fix yet
• No speculative mutation
• No multi-file edits
• No fix-forward behavior

────────────────────────────────

EXPECTED OUTPUT

This proof must produce:

• explicit correction of the wrong target
• real browser-facing operator-guidance anchors
• likely true single-file fix boundary
• next mutation constrained to one browser file only

────────────────────────────────

STATE

STABLE
CORRECTED
GUARDED
READY FOR REAL UI SURFACE ISOLATION

