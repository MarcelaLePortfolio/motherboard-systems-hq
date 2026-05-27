STATE NOTE — PHASE 79 RECOVERY-FIRST AUTOMATION CONSTRAINTS CONTRACT
Date: 2026-03-16

────────────────────────────────

PURPOSE

Define mandatory behavior any future advisory automation must follow when safety signals, instability, or uncertainty exist.

This ensures automation can never recommend actions that conflict with system protection discipline.

This is a behavioral contract only.

No runtime behavior changes are introduced.

────────────────────────────────

CORE PRINCIPLE

RECOVERY ALWAYS OVERRIDES PROGRESSION.

If safety signals exist:

System must favor:

Pause
Investigate
Recover

Never:

Accelerate
Continue blindly
Recommend mutation

Automation must reinforce safe engineering discipline, not undermine it.

────────────────────────────────

SAFETY SIGNAL CLASSES

Automation must recognize the following safety signal categories:

STRUCTURAL RISK
Layout drift
Contract violations
Missing protections
Integrity uncertainty

TELEMETRY RISK
Metric drift
Reducer inconsistency
Event ordering anomalies
State uncertainty

DIAGNOSTIC RISK
Missing signals
Degraded observability
Conflicting reports
Incomplete data

OPERATOR RISK
Unclear system state
Unclassified condition
Ambiguous workflow path

UNKNOWN STATE
Any condition not confidently classified.

────────────────────────────────

MANDATORY AUTOMATION RESPONSE MODEL

If ANY safety signal exists:

Automation must downgrade recommendations to:

OBSERVE
INVESTIGATE
RECOVERY-FIRST

Automation must NOT recommend:

Continue work
Add features
Extend systems
Execute plans
Change architecture

Safety signals freeze forward progression.

────────────────────────────────

RECOVERY PRIORITY ORDER

When multiple conditions exist:

Automation must recommend according to this strict order:

1 Structural safety
2 Telemetry integrity
3 Diagnostics clarity
4 Stable continuation

Automation must never reorder this priority.

Automation must never promote continuation above safety.

────────────────────────────────

UNCERTAINTY HANDLING RULE

If automation cannot determine safety:

Automation must return:

INSUFFICIENT CONFIDENCE

And recommend:

OBSERVE ONLY

Automation must never guess.

Automation must never assume safety.

Automation must never strengthen recommendations under uncertainty.

Uncertainty must weaken recommendations.

────────────────────────────────

PROGRESSION BLOCKING RULE

If any of the following exist:

Structural uncertainty
Telemetry drift
Diagnostic degradation
Unknown state

Automation must block forward recommendations.

Allowed outputs become:

Investigate
Observe
Recovery-first
Stabilize

Progression must pause until stability is restored.

────────────────────────────────

RECOVERY ALIGNMENT RULE

If a runbook recommends recovery-first:

Automation must align with it.

Automation must never suggest bypass.

Automation must never suggest delay.

Automation must never suggest optimization first.

Recovery discipline outranks efficiency.

────────────────────────────────

NO PRESSURE RULE

Automation must never:

Create urgency pressure
Suggest rushing
Frame delay as failure
Frame stabilization as loss

Automation must reinforce:

Stability first
Safety first
Determinism first

Speed is never a justification for risk.

────────────────────────────────

ADVISORY STRENGTH LIMIT

Automation recommendation strength must follow:

If stable:

May recommend continue carefully.

If minor uncertainty:

Recommend investigate first.

If moderate uncertainty:

Recommend observe.

If high uncertainty:

Recommend recovery-first.

If unknown:

Recommend halt.

Automation must scale down assertiveness as risk increases.

Never the opposite.

────────────────────────────────

FAIL-SAFE DEFAULT

If signals conflict:

Automation must default to:

RECOVERY-FIRST

If classification fails:

Automation must default to:

OBSERVE ONLY

If data is incomplete:

Automation must default to:

NO ACTION

Failure must always reduce action.

────────────────────────────────

BEHAVIOR SUMMARY

Automation must:

Protect stability
Protect telemetry integrity
Protect observability
Protect deterministic state
Protect recovery discipline

Automation must never:

Promote risk
Promote speed over safety
Promote continuation under uncertainty
Promote mutation under instability

────────────────────────────────

PHASE 79 SUCCESS CONDITION — RECOVERY CONSTRAINTS

Safety signal behavior defined
Priority ordering defined
Uncertainty behavior defined
Progression blocking defined
Recovery alignment defined
Fail-safe defaults defined

System remains unchanged.

────────────────────────────────

NEXT PLANNING ARTIFACT

NO-OP INTERFACE CONTRACT

Define how any future automation-facing interfaces must remain inert until explicitly approved.

END OF CONTRACT
