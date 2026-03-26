STATE CONTINUATION — GOVERNANCE SIGNAL TAXONOMY EXPANSION

(Post-Phase 248.4 planning artifact)

────────────────────────────────

PURPOSE

Define structured taxonomy for governance safety signals.

This establishes:

Primary signal classes
Secondary signal subclasses
Signal relationships
Interpretation priority

Documentation-only classification model.

No runtime behavior.
No signal wiring.
No execution interaction.

────────────────────────────────

PRIMARY SIGNAL CLASSES

SYSTEM STATE SIGNALS

Describe overall governance safety condition.

Examples:

SYSTEM_SAFE
SYSTEM_REVIEW_REQUIRED
SYSTEM_ATTENTION_REQUIRED
SYSTEM_UNSAFE
SYSTEM_UNKNOWN

Purpose:

Top-level operator cognition signal.

────────────────────────────────

CONSTRAINT SIGNALS

Represent individual constraint evaluations.

Examples:

CONSTRAINT_PASS
CONSTRAINT_WARN
CONSTRAINT_FAIL
CONSTRAINT_REVIEW

Purpose:

Expose specific governance rule outcomes.

────────────────────────────────

PREREQUISITE SIGNALS

Represent readiness conditions.

Examples:

PREREQUISITE_SATISFIED
PREREQUISITE_UNSATISFIED
PREREQUISITE_UNKNOWN

Purpose:

Expose execution eligibility conditions (advisory only).

────────────────────────────────

INTEGRITY SIGNALS

Represent structural system health.

Examples:

REGISTRY_INTEGRITY_OK
REGISTRY_INTEGRITY_DRIFT
TASK_STATE_INCONSISTENT
AGENT_DEFINITION_MISMATCH

Purpose:

Detect structural drift.

────────────────────────────────

AUTHORITY SIGNALS

Represent authority boundary health.

Examples:

AUTHORITY_CONFIRMED
AUTHORITY_UNCERTAIN
AUTHORITY_VIOLATION

Purpose:

Protect human authority guarantees.

────────────────────────────────

SECONDARY SIGNAL SUBCLASSES

Each primary class may contain subclasses.

Example:

SYSTEM STATE SIGNALS

Parent:
SYSTEM_ATTENTION_REQUIRED

Children:

SYSTEM_ATTENTION_OBSERVABILITY
SYSTEM_ATTENTION_PREREQUISITE
SYSTEM_ATTENTION_CONSTRAINT
SYSTEM_ATTENTION_INTEGRITY

Meaning:

Top-level signal explains category.
Subclass explains cause.

────────────────────────────────

SIGNAL RELATIONSHIP MODEL

Signals may relate through:

Parent relationships
Dependency relationships
Escalation relationships
Aggregation relationships

Example:

CONSTRAINT_FAIL
→ contributes to
SYSTEM_UNSAFE

PREREQUISITE_UNKNOWN
→ contributes to
SYSTEM_REVIEW_REQUIRED

Multiple signals may aggregate into one system state.

────────────────────────────────

SIGNAL INTERPRETATION PRIORITY

Priority order ensures deterministic cognition.

Highest priority:

SYSTEM_UNSAFE

Next:

AUTHORITY_VIOLATION

Next:

PREREQUISITE_UNSATISFIED

Next:

CONSTRAINT_FAIL

Next:

SYSTEM_REVIEW_REQUIRED

Next:

SYSTEM_ATTENTION_REQUIRED

Next:

SYSTEM_SAFE

Lowest:

SYSTEM_INFO

Meaning:

Higher severity dominates operator display.

────────────────────────────────

SIGNAL NORMALIZATION PRINCIPLE

Multiple signals must normalize into one top-level state.

Example:

If:

SYSTEM_SAFE
CONSTRAINT_WARN
PREREQUISITE_SATISFIED

Normalized state:

SYSTEM_ATTENTION_REQUIRED

Rule:

Highest severity wins.

────────────────────────────────

SIGNAL SAFETY PRINCIPLE

All signals must remain:

Informational
Advisory
Non-executing
Human-facing

Signals must never:

Trigger execution
Modify tasks
Modify registry
Command agents
Bypass operator authority

Signals inform only.

────────────────────────────────

SAFETY DECLARATION

This phase introduces:

No runtime logic
No reducers
No telemetry wiring
No worker integration
No registry interaction
No execution behavior
No UI logic
No policy engines

System remains:

Deterministic
Governance-first
Execution-gated
Human-authority preserved

────────────────────────────────

NEXT SAFE MODELING TARGET

Phase 248.5 candidate:

Governance Signal Normalization Rules

Goal:

Define deterministic rules for combining multiple governance signals into one system state.

Documentation-only continuation.

