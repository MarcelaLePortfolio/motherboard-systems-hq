PHASE 62B — METRICS HYDRATION IMPLEMENTATION PLAN
Date: 2026-03-11

Purpose:
Translate the Phase 62 metrics contract into an implementation checklist so hydration can be executed as a controlled data pass.

────────────────────────────────

IMPLEMENTATION ORDER (LOWEST RISK FIRST)

1 Active Agents (lowest risk)
2 Tasks Running
3 Success Rate
4 Latency (highest complexity)

Rationale:
Start with existing UI-bound data sources before lifecycle calculations.

────────────────────────────────

METRIC IMPLEMENTATION MAP

Active Agents

Source:
Agent runtime status feed

Likely files:

public/js/agent-status-row.js
public/bundle.js

Binding plan:

• Locate existing agent status object
• Identify last activity timestamp or online flag
• Count agents active within 60 seconds
• Bind value to telemetry tile
• Display fallback "—" if unavailable

Verification:

• Matches visible agent pool state
• Layout verifier passes
• No HTML changes

Status:
NOT STARTED

────────────────────────────────

Tasks Running

Source:

run_view or task lifecycle API

Binding plan:

• Identify source of latest task state
• Filter non-terminal states
• Count running tasks
• Bind to tile

Verification:

• Matches Recent Tasks panel behavior
• No lifecycle logic duplicated in UI

Status:
NOT STARTED

────────────────────────────────

Success Rate

Source:

Recent runs lifecycle summary

Binding plan:

• Retrieve last 50 terminal runs
• Count completed
• Count failed
• Calculate percentage
• Format display

Verification:

• Manual sample check
• Matches lifecycle states

Status:
NOT STARTED

────────────────────────────────

Latency

Source:

Run lifecycle timestamps

Binding plan:

• Retrieve last 25 completed runs
• Calculate duration
• Compute average
• Format ms vs seconds

Verification:

• Spot check durations
• Ensure units correct

Status:
NOT STARTED

────────────────────────────────

PHASE 62B EXECUTION RULES

Do NOT:

• Modify dashboard.html
• Change layout IDs
• Add containers
• Change grid
• Touch Atlas band

Only modify:

public/js/*
public/bundle.js

────────────────────────────────

EXECUTION CHECKLIST

For each metric:

1 Locate source
2 Implement calculation
3 Bind tile value
4 Handle fallback display
5 Run layout verifier
6 Rebuild container
7 Visual confirmation
8 Commit

────────────────────────────────

SUCCESS CONDITION

All metrics display live values.

Layout contract passes.

No visual structure changes.

