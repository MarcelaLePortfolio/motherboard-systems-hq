# Phase 58C — Empty States & Cold-Start Presentation

## Objective
Make fresh boot dashboard presentation feel intentional, calm, and operator-ready even when there is little or no workload.

## Scope
Dashboard/UI only.

Do **not** modify:
- backend APIs
- task lifecycle logic
- policy system
- database schema

Use existing surfaces only:
- /api/health
- /api/runs
- /api/tasks
- task events stream

## Problems Observed
1. Most panels appear empty without explanation.
2. Fresh boot can feel unfinished rather than intentionally idle.
3. Operators must infer whether emptiness means healthy-idle or broken-loading.
4. Visual hierarchy does not yet reassure the operator on first glance.

## Goals
1. Distinguish loading, empty, active, and terminal states clearly.
2. Make fresh boot read as healthy and ready, not sparse and confusing.
3. Reduce debug-surface feeling through better panel copy and spacing.
4. Preserve observability while improving calmness and clarity.

## Implementation Guidance

### 1. Explicit Panel States
Each major panel should visibly represent one of:
- loading
- healthy but idle
- active
- terminal/history available

Do not leave blank containers without context.

### 2. Empty State Copy
Use concise operator-facing copy.

Examples:
- No active workload yet
- Waiting for run activity
- Recent probe activity will appear here
- System healthy and ready

### 3. Cold-Start Hierarchy
On fresh boot, emphasize in order:
1. system health
2. probe run visibility
3. recent lifecycle events
4. secondary/empty panels

### 4. Loading Behavior
Use a stable loading treatment that does not jitter or reflow heavily.

Loading should communicate:
- the panel is expected
- data is being fetched
- absence is temporary

### 5. Layout Calmness
Improve:
- spacing
- padding
- card balance
- alignment
- section labeling

The dashboard should feel like an operator console, not a temporary debug arrangement.

### 6. Empty vs Broken
Where possible using current data only, visually distinguish:
- no data yet
- unavailable data
- loading in progress

Do not invent backend state. Only present the current frontend condition clearly.

## Demo Success Criteria
On fresh boot, an operator should immediately understand:

1. the system is healthy
2. the probe area is the primary live signal
3. empty panels are intentionally idle, not broken
4. the dashboard is ready for real workload visibility

## Out of Scope
- backend retry logic
- new endpoints
- lifecycle changes
- policy changes

## Next Phase
Phase 58D — Operator Console Visual Hierarchy
