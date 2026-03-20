# PHASE 63.1 METRIC SOURCE AUDIT FINDINGS
Date: 2026-03-12

## Summary

Initial source tracing confirms that all four System Metrics tiles are bound to dedicated DOM anchors and currently compute in-browser from SSE event streams.

## Metric Binding Targets

Verified dedicated value anchors in `public/dashboard.html`:

- `metric-agents`
- `metric-tasks`
- `metric-success`
- `metric-latency`

## Current Source Map

### Active Agents

DOM target:
- `metric-agents`

Current source:
- `/events/ops`
- `ops.state`

Current calculation:
- count agents with activity inside a 60-second window

Assessment:
- event source is distinct from task metrics
- currently acceptable, but still browser-derived rather than centrally normalized

### Tasks Running

DOM target:
- `metric-tasks`

Current source:
- `/events/task-events`

Current calculation:
- maintains in-browser `runningTaskIds`
- adds/removes task IDs based on event type classification

Assessment:
- provisional browser-side derivation
- should be reviewed for canonical event classification and duplicate stream handling

### Success Rate

DOM target:
- `metric-success`

Current source:
- `/events/task-events`

Current calculation:
- maintains in-browser `completedCount` and `failedCount`
- computes percentage from observed terminal events

Assessment:
- provisional browser-side rolling total
- may underrepresent history if page loads mid-stream or sample window is incomplete

### Latency

DOM target:
- `metric-latency`

Current source:
- `/events/task-events`

Current calculation:
- stores per-task start timestamps in-browser
- computes duration on terminal event
- averages `recentDurationsMs`

Assessment:
- provisional browser-side sample model
- useful for visibility, but not yet a canonical runtime metric

## Integrity Observations

Current telemetry model is stable but still largely client-derived.

This means Phase 63.1 should focus on:

- confirming canonical event classifications
- identifying duplicate/fallback calculation paths
- deciding whether these metrics remain browser-derived or move to a normalized producer path

## Next Step

Proceed to a calculation-path audit for:

- event type classification
- duplicate EventSource usage
- terminal event semantics
- sample-window assumptions

