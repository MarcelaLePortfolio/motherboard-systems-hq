PHASE 401.3 — TRUST VISIBILITY RULES

Defines deterministic rules governing how trust classification becomes visible to operator cognition surfaces.

Purpose:

Ensure operator can clearly see cognition trust state without ambiguity, interpretation burden, or hidden conditions.

Classification exposure only.
No UI implementation.
No runtime integration.
No dashboard wiring.

────────────────────────────────

VISIBILITY PRINCIPLE

Trust must be:

Explicit  
Non-implicit  
Non-derived  
Directly attached to cognition output  

Operator must never infer trust.

System must always state trust.

────────────────────────────────

MANDATORY EXPOSURE RULE

Every governance cognition packet must expose:

trust_state
trust_reason
trust_evidence

Packets missing trust classification must be considered:

TRUST_UNVERIFIED

No exceptions.

────────────────────────────────

VISIBILITY INVARIANT

Trust visibility must be:

Stable
Deterministic
Immutable after packaging

Trust state cannot change after exposure unless:

Governance recomputation occurs.

Meaning:

Trust is tied to cognition version.

Not session timing.

────────────────────────────────

VISIBILITY PLACEMENT RULE

Trust must be visible:

At cognition origin
At cognition summary
At cognition investigation view

Trust must never be:

Hidden in logs
Hidden in diagnostics
Only visible in deep views

Trust must exist at first operator contact point.

────────────────────────────────

VISIBILITY CLARITY RULE

Trust must never be:

Encoded symbolically
Represented by color only
Represented by icons only
Represented by abbreviations alone

Trust must always include:

Full trust_state text.

Example:

TRUST_VERIFIED

Not:

TV
✓
Green indicator alone

Symbols may supplement.

Never replace text.

────────────────────────────────

VISIBILITY EXPLANATION RULE

Trust must always include explanation.

Minimum:

trust_reason

Optional:

trust_evidence

Operator must never need investigation just to understand trust state.

────────────────────────────────

VISIBILITY SAFETY RULE

Trust visibility must never:

Alter execution decisions
Alter task routing
Alter governance decisions
Alter reducer behavior

Trust communicates cognition reliability only.

────────────────────────────────

VISIBILITY CONSISTENCY RULE

Identical cognition must always produce:

Identical trust state.

No session variation.
No ordering effects.
No exposure timing variation.

Trust must be reproducible from governance inputs only.

────────────────────────────────

VISIBILITY FAILURE RULE

If trust cannot be computed:

System must default:

TRUST_UNVERIFIED

Never:

Assume trust.
Hide trust.
Delay trust.

Default must be safe classification.

────────────────────────────────

PHASE BOUNDARY

Phase 401.3 establishes:

Trust visibility guarantees
Trust exposure invariants
Trust presentation constraints

Does NOT establish:

Trust UI design
Trust indicators
Trust rendering strategy

Those belong to Phase 401.4+

────────────────────────────────

PHASE 401.3 COMPLETE

