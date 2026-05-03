PHASE 82.2 — Composition Registry

Objective:

Formally register composed signals while preserving interpretation-only authority.

Scope:

Registry structure only.
No runtime wiring.
No reducer coupling.
No dashboard coupling.
No automation hooks.

Registry purpose:

Ensure composed signals are:

Named
Traceable
Deterministic
Interpretation-only
Non-authoritative

Registry definition:

Each composed signal must declare:

name
source signals
interpretation purpose
authority level
safety classification

Required fields:

name:string

signals:string[]

interpretation:string

authority:"interpretation_only"

stability:"deterministic"

runtimeCoupled:false

automationCoupled:false

behaviorCoupled:false

phaseIntroduced:"82"

status:"active"

Example structure:

{
 name: "operator_load_context",
 signals: [
   "queue_pressure",
   "success_rate",
   "failure_rate"
 ],
 interpretation: "operator context signal",
 authority: "interpretation_only",
 stability: "deterministic",
 runtimeCoupled: false,
 automationCoupled: false,
 behaviorCoupled: false,
 phaseIntroduced: "82",
 status: "active"
}

Registry rules:

Composed signals may not:

Trigger behavior
Change task flow
Change priority
Change scheduling
Trigger policy

Composed signals may only:

Inform operators
Inform diagnostics
Support future safe displays
Support runbook interpretation

Suggested location:

src/lib/signals/compositionRegistry.ts

Phase completion criteria:

Registry structure defined
Safety rules documented
No runtime imports
No authority expansion
Interpretation boundary preserved

Prepares:

Phase 82.3 composition closure

