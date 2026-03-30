PHASE 401.2 — TRUST CLASSIFICATION MODEL

Defines deterministic rules for how governance assigns trust states.

Purpose:

Ensure trust classification is reproducible, explainable, and invariant-driven.

Classification only.
No runtime wiring.
No UI integration.
No execution coupling.

────────────────────────────────

CLASSIFICATION PRINCIPLE

Trust state must be derived from governance verification results only.

Trust must be:

Deterministic  
Recomputable  
Invariant-driven  
Evidence-based  

Trust must never depend on:

Timing
Operator interpretation
Agent narrative
Heuristic scoring
Probability weighting

────────────────────────────────

CLASSIFICATION ORDER (STRICT)

Trust classification must follow this evaluation order:

1 Packaging correctness
2 Invariant validation
3 Replay verification
4 Diagnostic completeness
5 Investigation coverage

Trust state must equal the lowest satisfied condition.

Meaning:

Weakest verified layer determines trust.

Example:

Packaging verified
Replay incomplete

Result:

TRUST_CONDITIONED

Never TRUST_VERIFIED.

────────────────────────────────

TRUST STATE CONDITIONS

TRUST_VERIFIED requires:

Packaging verification passed
Invariant checks passed
Replay alignment confirmed
Diagnostics complete
Investigation coverage complete

All required.

────────────────────────────────

TRUST_CONDITIONED requires:

Packaging valid
No invariant violations
Replay OR investigation incomplete

Examples:

Missing telemetry
Partial replay
Incomplete investigation corridor

────────────────────────────────

TRUST_DEGRADED requires:

Packaging valid
But one or more reliability weakeners:

Replay discontinuity
Diagnostic gaps
Signal conflicts

No invariant break required.

────────────────────────────────

TRUST_UNVERIFIED requires:

Packaging incomplete OR
Verification corridor incomplete OR
Early investigation stage

No correctness guarantees.

────────────────────────────────

CLASSIFICATION INVARIANT

Trust classification must always be:

Monotonic.

Meaning:

New verification may only increase trust.

Never decrease trust unless:

New invariant violation discovered.

────────────────────────────────

TRUST ESCALATION RULE

Allowed transitions:

UNVERIFIED → CONDITIONED  
CONDITIONED → VERIFIED  

DEGRADED → CONDITIONED  
DEGRADED → VERIFIED

Never:

VERIFIED → DEGRADED
VERIFIED → UNVERIFIED

Unless invariant violation discovered.

────────────────────────────────

TRUST EXPLANATION REQUIREMENT

Every classification must produce:

trust_state
trust_reason
trust_evidence

trust_reason must be human readable.

trust_evidence must reference:

verification checks
diagnostic results
replay checks
packaging results

────────────────────────────────

CLASSIFICATION SAFETY RULE

Trust classification must never:

Influence execution routing
Influence governance routing
Influence reducers
Influence agents
Trigger automation

Trust is descriptive only.

────────────────────────────────

PHASE BOUNDARY

Phase 401.2 establishes:

Trust classification rules
Trust transition logic
Trust derivation guarantees

Does NOT establish:

Trust visibility rules
Trust presentation rules
Trust signaling surfaces

Those belong to Phase 401.3+

────────────────────────────────

PHASE 401.2 COMPLETE

