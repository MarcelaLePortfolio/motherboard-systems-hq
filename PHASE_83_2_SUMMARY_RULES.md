PHASE 83.2 — SUMMARY RULES

Purpose:

Define the rule set governing what summaries may contain,
how summaries may speak,
and what boundaries summaries must preserve.

This phase defines:

Summary language rules
Interpretation boundaries
Allowed content
Forbidden content
Scope discipline
Determinism discipline

This phase does NOT define:

Summary generation logic
Summary reducers
Summary registry entries
Summary rendering
Summary automation hooks
Summary policy hooks

This is rules only.

────────────────────────────────

RULE INTENT

Summary rules exist to ensure summaries remain:

Interpretation-only
Deterministic
Non-authoritative
Readable
Bounded
Safe

Summaries must reduce cognitive load without increasing control surface.

────────────────────────────────

PRIMARY RULESET

Rule 1 — Descriptive only

Summaries may describe conditions.

Summaries may not prescribe responses.

Allowed:
"Queue pressure is elevated but remains below critical range."

Forbidden:
"Operator should intervene now."


Rule 2 — No imperative language

Summaries may not contain commands.

Forbidden examples:
"Investigate immediately."
"Pause execution."
"Escalate now."
"Retry task."
"Take action."

Summaries must not tell the operator what to do.


Rule 3 — No decision language

Summaries may not imply authoritative conclusions.

Forbidden examples:
"Intervention required."
"Execution should stop."
"Route should change."
"Policy should apply."

Summaries may describe observed meaning only.


Rule 4 — No trigger semantics

Summaries may not behave like triggers.

Forbidden examples:
"If pressure rises, escalate."
"This condition should start recovery."
"Crossing this threshold should notify the operator."

Summaries must not imply causal system behavior.


Rule 5 — No policy semantics

Summaries may not classify policy status.

Forbidden examples:
"System is compliant."
"Policy violation detected."
"Grant required."
"Authorization mismatch."

Policy interpretation belongs elsewhere.


Rule 6 — No probabilistic wording

Summaries must remain deterministic.

Forbidden examples:
"Likely unstable."
"Possibly overloaded."
"May require review."
"Probably safe."

Allowed wording must describe current interpreted state only.


Rule 7 — No hidden inputs

Every summary must derive only from explicit source signals.

No unstated assumptions.
No implicit history.
No invisible weighting.

Traceability must remain intact.


Rule 8 — No authority drift

All summaries must preserve:

authority = "interpretation_only"

No summary may increase authority through wording, structure, or implication.


Rule 9 — Scope honesty

Summary scope must match actual breadth.

Local summaries may not sound system-wide.
System summaries may not pretend to be narrow.

Interpretation breadth must be structurally honest.


Rule 10 — Operator-readable language

Summaries must be readable by a human operator.

Allowed style:
clear
direct
descriptive
bounded

Forbidden style:
symbolic
poetic
vague
performative
instructional


Rule 11 — No runtime dependence

Summary content may not depend on:

timers
wall-clock conditions
live mutable state
external runtime side effects

Summaries must remain reproducible from signal inputs alone.


Rule 12 — No execution semantics

Summaries may not contain:

task commands
workflow commands
routing guidance
mutation guidance
scheduling advice
control instructions

Summaries explain.
They do not execute.

────────────────────────────────

ALLOWED CONTENT

Summaries may contain:

Observed interpretation
Signal-derived condition meaning
Cross-signal context
Bounded operational framing
Operator-readable condition explanations

Examples:

"Queue pressure is elevated while throughput remains stable."
"Failure pressure is present but system conditions remain bounded."
"Signals indicate localized stress without system-wide instability."

────────────────────────────────

FORBIDDEN CONTENT

Summaries may not contain:

Commands
Advice
Predictions
Probabilities
Escalation directives
Policy judgments
Task routing implications
Scheduling implications
Behavior triggers

Forbidden examples:

"Escalation is needed."
"Retry the queue."
"This will probably fail."
"Operator should reroute workload."
"Pause new tasks."

────────────────────────────────

LANGUAGE DISCIPLINE

Preferred wording style:

"is"
"remains"
"indicates"
"reflects"
"shows"
"suggests" is not allowed if probabilistic
"demonstrates" allowed only when deterministic

Preferred sentence behavior:

Descriptive
Bounded
Present-state oriented
Signal-traceable

Avoid:

"should"
"must"
"need to"
"likely"
"maybe"
"probably"
"recommend"
"escalate"
"intervene"

────────────────────────────────

SUMMARY EXAMPLES

Valid:

"Queue pressure is elevated but remains below critical classification."

Valid:

"Composed signals reflect moderate system strain without instability."

Valid:

"Signal pattern indicates localized execution stress."

Invalid:

"Operator should monitor closely."

Invalid:

"System may be heading toward overload."

Invalid:

"Immediate intervention is recommended."

Invalid:

"Policy review is required."

────────────────────────────────

RULE ENFORCEMENT POSITION

These rules increase:

Interpretation safety
Operator clarity
Authority containment
Summary consistency

These rules do NOT increase:

System authority
Runtime surface
Reducer surface
Automation surface
Policy surface
Execution surface

────────────────────────────────

SUCCESS CRITERIA

Phase considered complete when:

Summary content rules defined
Allowed language defined
Forbidden language defined
Scope discipline defined
Authority discipline preserved
Determinism discipline preserved
No implementation logic introduced
No runtime coupling introduced

This prepares:

Phase 83.3 Summary Registry

System status after completion:

STABLE
SAFE
COGNITION-ONLY
RULE-BOUND

