PHASE 62 — METRICS DATA CONTRACT
Operator Telemetry Definitions
Date: 2026-03-11

────────────────────────────────

PURPOSE

This document defines the data contract for Phase 62B metrics telemetry hydration.

These definitions establish the authoritative meaning of all dashboard telemetry tiles and prevent semantic drift during future development.

This is a DATA CONTRACT.
Not a layout document.

Layout structure is governed by:

PHASE62_2_LAYOUT_CONTRACT_PROTECTED_STABLE_20260311.md

This document governs:

• metric meaning
• calculation rules
• data sources
• fallback behavior
• implementation constraints

────────────────────────────────

PHASE 62B SCOPE

Phase 62B is strictly:

Telemetry hydration.

Allowed:
• data binding
• value formatting
• calculation logic
• fallback handling

Not allowed:
• layout changes
• HTML restructuring
• ID mutations
• grid changes
• tile additions
• tile removals

This phase is DATA ONLY.

────────────────────────────────

METRICS DEFINITIONS (AUTHORITATIVE)

Active Agents

Definition:
Number of agents reporting runtime activity within the last 60 seconds.

Agents included:

Matilda  
Atlas  
Cade  
Effie  

Calculation rule:

active if:

current_time - last_activity ≤ 60s

Purpose:
System health signal.

Operator meaning:
Indicates agent runtime availability.

Data source:
Agent runtime status / agent registry feed.

Fallback:
Display:

—

Never display 0 unless explicitly confirmed.

────────────────────────────────

Tasks Running

Definition:
Number of tasks whose latest lifecycle state is non-terminal.

Terminal states include:

completed  
failed  
cancelled  

May include additional terminal states if defined by lifecycle contract.

Calculation rule:

Count tasks where:

latest_state NOT IN terminal_states

Purpose:
System throughput signal.

Operator meaning:
Indicates active workload.

Data source:
Task lifecycle state from run_view or task_events.

Preferred source:
Server-derived lifecycle state.

Avoid:
Client-side lifecycle reconstruction when server state exists.

Fallback:
Display:

—

Not 0.

────────────────────────────────

Success Rate

Definition:

completed_runs / (completed_runs + failed_runs)

Measured over:

Last 50 terminal runs.

Include:

completed  
failed  

Exclude:

cancelled  
aborted  
expired  
non-success terminal states  

Purpose:
System reliability signal.

Operator meaning:
Indicates execution stability.

Calculation rule:

success_rate =

completed /
(completed + failed)

Formatting:

Display as percentage.
Round to whole number or 1 decimal maximum.

Examples:

96%
94.5%

Fallback:
Display:

—

────────────────────────────────

Latency

Definition:

Average execution duration over last 25 completed runs.

Calculation:

completed_timestamp - started_timestamp

Window:

Last 25 completed runs.

Purpose:
System performance signal.

Operator meaning:
Indicates execution speed and pressure.

Data source:

Run lifecycle timestamps from run_view or lifecycle summary source.

Formatting rules:

Under 1000 ms:

display in ms

Example:

842 ms

1 second or higher:

display in seconds

Example:

1.4 s

Fallback:
Display:

—

────────────────────────────────

IMPLEMENTATION CONSTRAINTS

Phase 62B must not:

• Modify dashboard layout
• Change layout IDs
• Change grid structure
• Move Atlas band
• Add tiles
• Remove tiles
• Change workspace structure

Allowed changes:

• JS data binding
• Value calculation
• Formatting logic
• Fallback display logic

Primary modification locations:

public/js/
public/bundle.js

HTML must remain unchanged.

────────────────────────────────

FALLBACK RULES

If metric data unavailable:

Display:

—

Never display:

0

Unless confirmed true value.

Reason:

0 implies measured state.
— implies not yet hydrated.

────────────────────────────────

NON-GOALS

Phase 62B does NOT include:

New metrics  
Historical dashboards  
Trend graphs  
Error categorization  
Worker utilization metrics  
Queue depth metrics  

These belong to future phases.

────────────────────────────────

PHASE 62B SUCCESS CRITERIA

Metrics display live values.

Layout verifier passes.

No layout contract violations.

No ID mutations.

No structural changes.

Dashboard remains visually identical except telemetry values.

────────────────────────────────

END OF CONTRACT
