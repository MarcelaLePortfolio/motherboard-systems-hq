STATE NOTE — PHASE 66 OBSERVABILITY EXPANSION PLANNING
Observability Expansion Design Corridor
Date: 2026-03-16

────────────────────────────────

OBJECTIVE

Expand dashboard observability without structural mutation.

STRICT RULES

DATA ONLY CHANGES.
NO layout mutation.
NO container movement.
NO DOM restructuring.
NO ID mutation.
NO script mount order changes.

Layout contract must remain passing.
Protection corridor must remain passing.
Ownership map must remain passing.

────────────────────────────────

PHASE 66 TARGET AREAS

New observability metrics must follow:

Deterministic data source  
Single reducer ownership  
No metric overlap  
No duplicate telemetry streams  
No structural expansion required  

Initial candidate metrics:

Queue Depth  
Failed Tasks  
Task Throughput  
Task Success Rate  
Agent Activity Rate  
Event Lag Detection  

────────────────────────────────

PROPOSED METRIC ORDER (NON-STRUCTURAL)

System Metrics Tile Expansion (data only):

Existing tiles remain unchanged.

Future additions must either:

Reuse existing metric slots
OR
Replace temporary hydration placeholders
OR
Use rotation logic (future)

No new tiles without Phase approval.

────────────────────────────────

QUEUE DEPTH METRIC DESIGN

SOURCE:

/events/task-events stream

Model:

Queue Depth =

COUNT(tasks where state:

created
queued

MINUS

COUNT(tasks where state:

started
completed
failed
cancelled

Preferred deterministic model:

Maintain queue set:

ADD:

task.created
task.queued

REMOVE:

task.started
task.completed
task.failed
task.cancelled

Queue Depth =
size(queue_set)

Owner:

telemetry_queue_depth_reducer.js (new)

────────────────────────────────

FAILED TASK METRIC DESIGN

SOURCE:

task.failed events

Model:

Failed Tasks (rolling window):

COUNT(task.failed last N minutes)

Future:

24h failure window
Failure rate %
Agent failure attribution

Owner:

telemetry_failure_reducer.js (new)

────────────────────────────────

THROUGHPUT METRIC DESIGN

SOURCE:

task.completed events

Model:

Throughput =

COUNT(completed last N minutes)

Future:

Per-agent throughput
Throughput trend

Owner:

telemetry_throughput_reducer.js (future)

────────────────────────────────

VERIFICATION IMPROVEMENTS

Add verification scripts:

phase66_metric_collision_check.sh

Verifies:

No duplicate metric reducers
No overlapping ownership
No layout mutation
Protection gate passes

Future:

Metric ownership registry file:

docs/telemetry/METRIC_OWNERSHIP_MAP.md

────────────────────────────────

SAFE IMPLEMENTATION ORDER

Phase 66A

Design metric reducers only

Phase 66B

Wire queue depth metric

Phase 66C

Wire failed task metric

Phase 66D

Add verification improvements

Each must pass protection gate.

────────────────────────────────

SAFE DEVELOPMENT RULE

Every metric must:

Declare owner
Declare source events
Declare removal events
Declare deterministic model

No shared reducers.

────────────────────────────────

PROTECTION CHECK BEFORE ANY METRIC WORK

Run:

bash scripts/_local/phase65_pre_commit_protection_gate.sh

Verify:

Layout contract passing
Protected files unchanged
No structural drift
Ownership map valid

Only then continue.

────────────────────────────────

SUCCESS CONDITIONS

Phase 66 planning considered complete when:

Metric designs documented
Ownership declared
No layout changes required
Protection remains green

Implementation may then begin.

────────────────────────────────

NEXT EXECUTION TARGET

Phase 66A — Queue Depth reducer design.

No UI change.

Data layer only.

────────────────────────────────

END OF PHASE 66 PLANNING
