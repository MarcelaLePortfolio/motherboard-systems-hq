STATE NOTE — PHASE 67E BINDING TARGET SELECTION
Binding Target Selection Corridor
Date: 2026-03-16

────────────────────────────────

OBJECTIVE

Select safe existing compact metric targets for future reducer binding
without structural mutation.

NO layout changes.
NO wrapper additions.
NO ID changes.
NO tile growth.
NO ownership overlap.

────────────────────────────────

DISCOVERY RESULT

Current compact metric IDs discovered:

metric-agents
metric-tasks
metric-success
metric-latency

Current ownership references discovered:

metric-agents  → phase64_agent_activity_wire.js
metric-tasks   → telemetry/running_tasks_metric.js
metric-success → telemetry/success_rate_metric.js
metric-latency → telemetry/latency_metric.js

Ownership comments in agent-status-row.js confirm these transfers.

────────────────────────────────

SELECTION DECISION

Existing compact metric IDs are already owned.

Therefore:

Queue depth:
NO SAFE EXISTING SLOT AVAILABLE

Failed task count:
NO SAFE EXISTING SLOT AVAILABLE

Reason:

All discovered compact metric IDs already have active owners or
ownership guards.

Binding either new reducer into those IDs would create ownership overlap
and violate the protected telemetry ownership model.

────────────────────────────────

NON-NEGOTIABLE CONCLUSION

Phase 67 must NOT implement metric readout binding into current compact
metric surface.

Doing so would introduce one or more of:

Ownership collision
Readout ambiguity
Guard violation
Silent metric drift

This phase therefore ends with a NO-BIND decision.

────────────────────────────────

SAFE NEXT OPTIONS

Option A

Create a future approved observability phase that explicitly reallocates
an existing metric tile owner.

Option B

Add a separate non-compact readout surface only through a later
authorized layout phase.

Option C

Keep reducers unbound and use them only for verification / future
planning until a safe ownership corridor is created.

Preferred option now:

Option C

────────────────────────────────

RULE FORWARD

No reducer may bind to:

metric-agents
metric-tasks
metric-success
metric-latency

unless ownership is explicitly transferred in a future narrow phase.

────────────────────────────────

NEXT EXECUTION TARGET

Phase 67F — No-Bind checkpoint

Document that runtime compatibility and event-shape inspection passed,
but binding is intentionally blocked by ownership protection.

────────────────────────────────

END PHASE 67E SELECTION
