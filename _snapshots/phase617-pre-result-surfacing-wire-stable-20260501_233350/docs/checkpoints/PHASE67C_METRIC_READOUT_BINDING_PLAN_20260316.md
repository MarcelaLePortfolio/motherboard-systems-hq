STATE NOTE — PHASE 67C METRIC READOUT BINDING PLAN
Metric Readout Binding Corridor
Date: 2026-03-16

────────────────────────────────

OBJECTIVE

Plan safe binding of Phase 66 reducers into existing compact metric surface.

NO layout changes.
NO new wrappers.
NO ID changes.
NO tile growth.

────────────────────────────────

BINDING TARGETS

Reducer sources:

public/js/telemetry_queue_depth_reducer.js
public/js/telemetry_failed_tasks_reducer.js

Protected surface constraint:

Existing compact metric tiles only.

Candidate binding approach:

Bind queue depth to an existing compact metric tile text node.
Bind failed task count to an existing compact metric tile text node.

No new DOM structure permitted.

────────────────────────────────

SAFE BINDING RULES

Binding layer must:

Read reducer values only
Write textContent only
Use existing metric tile IDs only
Fail closed if target element absent
Avoid reducer mutation
Avoid shared ownership overlap

Binding layer must NOT:

Create nodes
Append wrappers
Change classes
Change layout containers
Change protected files

────────────────────────────────

PRE-BINDING REQUIREMENTS

Before implementation:

1 Confirm exact existing metric tile IDs
2 Confirm those IDs are not owned by protected files
3 Confirm no existing metric module already owns target tile
4 Confirm reducer globals are readable after bundle load
5 Re-run Phase 67B inspection
6 Re-run Phase 66 collision check
7 Re-run Phase 65 protection gate

────────────────────────────────

BINDING OWNERSHIP MODEL

Proposed binding file:

public/js/telemetry/phase67c_metric_readout_binding.js

Ownership rule:

This file owns readout binding only.
Reducers remain sole owners of reducer state.
No ownership crossover allowed.

────────────────────────────────

IMPLEMENTATION SHAPE

Binding loop:

On interval or safe event tick:

Read:
window.queueDepthTelemetry?.getQueueDepth?.()
window.failedTasksTelemetry?.getFailedTaskCount?.()

Write:
existingMetricEl.textContent = String(value)

Use textContent only.

If reducer global unavailable:
do nothing

If metric element unavailable:
do nothing

────────────────────────────────

VERIFICATION TARGETS

Binding phase passes if:

No protected file changed
No structural drift detected
No metric ownership collision introduced
Reducers remain isolated
Existing tile text updates safely
Dashboard interactivity unchanged

────────────────────────────────

NEXT EXECUTION TARGET

Phase 67D — metric slot discovery and ownership mapping.

Only inspect current metric IDs and current owners.
No binding implementation yet.

────────────────────────────────

END PHASE 67C PLAN
