PHASE 81.7 — Queue Pressure Signal Registry Entry

Objective:

Register queue pressure as a formally recognized interpreted signal
inside the signal layer without introducing runtime coupling.

Scope:

Registry only.
No reducer changes.
No dashboard wiring.
No behavior triggers.
No automation hooks.

Signal identity:

Signal name:
queue_pressure

Signal class:
derived_interpretation_signal

Source:
queue throughput
queue latency
task lifecycle duration
task execution duration

Definition:

Queue pressure is a normalized interpreted signal representing
aggregate operational strain across queue flow and task timing.

It is not an authority signal.
It is not an automation trigger.
It is not a control surface.

Allowed uses:

• Operator interpretation
• Diagnostic context
• Runbook context
• Safe future display expansion
• Deterministic signal classification

Forbidden uses:

• Autonomous behavior execution
• Automatic intervention
• Policy escalation
• Task mutation
• Scheduling mutation
• Self-expansion

Required registry fields:

name: "queue_pressure"
kind: "signal"
class: "derived_interpretation_signal"
stability: "deterministic"
authority: "human_interpreted_only"
runtimeCoupled: false
automationCoupled: false
dashboardRequired: false
safeForFutureExposure: true
phaseIntroduced: "81"
status: "active"

Associated interpretation levels:

LOW
ELEVATED
HIGH
CRITICAL
UNKNOWN

Associated components:

deriveQueuePressure
classifyQueuePressure

Required notes:

Queue pressure is interpretation-only.
Queue pressure does not alter behavior.
Queue pressure remains bounded by cognition-only doctrine.

Suggested file target:

src/lib/signals/signalRegistry.ts

Registry rule:

Entry must remain declarative.
No computed behavior inside registry.
No imports from dashboard or reducer layers.

Phase completion criteria:

Registry entry added
Signal metadata complete
No runtime coupling introduced
No authority expansion introduced

Completion advances system toward:

Phase 81.8 signal layer closure

