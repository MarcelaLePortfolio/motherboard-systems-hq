PHASE 456 — STEP 3
DASHBOARD EXPOSURE PLACEMENT DEFINITION

CLASSIFICATION:
STRUCTURAL PLACEMENT DESIGN

NO RUNTIME MUTATION
NO ARCHITECTURE CHANGE
NO UI WIRING YET

Define placement only.

────────────────────────────────

OBJECTIVE

Define where new exposure panels belong so the dashboard
reflects real FL-3 capability without increasing complexity.

Goal:

Operator must understand system state in <5 seconds.

Placement must improve clarity,
not add noise.

────────────────────────────────

PLACEMENT PRINCIPLES

Exposure must follow hierarchy:

System State
→ Planning State
→ Execution State
→ Capability State

Operator reads top → down.

Never mix planning and execution signals.

Never bury readiness signals.

────────────────────────────────

CURRENT DASHBOARD STRUCTURE

Observed zones:

HEADER
Operator Console (health + uptime)

LEFT COLUMN
Agent Pool
Runtime stats

CENTER
Operator Workspace (Matilda chat)

RIGHT
Operator Guidance (SSE stream)

────────────────────────────────

REQUIRED PLACEMENT CHANGES

1 — HEALTH SEMANTIC CORRECTION

Placement:

Operator Console header.

Replace:

Health: Critical

With:

Health: DEMO CAPABLE

Reason:

Health belongs to system state tier.

Top visibility required.

────────────────────────────────

2 — MATILDA PLANNING PANEL

Placement:

Directly under Operator Workspace.

Reason:

Planning belongs between:

Operator request
and
Execution readiness.

Logical flow:

Operator Workspace
→ Planning State
→ Execution State

Panel title:

Planning Status

────────────────────────────────

3 — EXECUTION READINESS PANEL

Placement:

Directly below Planning Status.

Reason:

Execution must follow planning in visual hierarchy.

Panel title:

Execution Readiness

Order:

Planning Status
Execution Readiness

Never reversed.

────────────────────────────────

4 — CAPABILITY SUMMARY PANEL

Placement:

Right column under Operator Guidance.

Reason:

Capability summary is informational,
not operational.

Must not interrupt execution flow.

Panel title:

System Capability Status

────────────────────────────────

FINAL DASHBOARD FLOW

TOP:

Operator Console
(Health corrected)

CENTER FLOW:

Operator Workspace
↓
Planning Status
↓
Execution Readiness

RIGHT COLUMN:

Operator Guidance
↓
System Capability Status

LEFT COLUMN:

Agent Pool (unchanged)

────────────────────────────────

STEP 3 RESULT

Placement defined.

No wiring performed.

No UI mutation performed.

No architecture change.

Checkpoint stability preserved.

────────────────────────────────

NEXT STEP

STEP 4 — Exposure surface alignment

Define minimal UI additions required to surface these panels
without introducing behavior.

Definition only.

