# PHASE 63.3 LATENCY METRIC PROVENANCE FINDINGS
Date: 2026-03-12

## Summary

Initial Phase 63.3 latency metric provenance findings captured from the verified Phase 63.2 golden baseline.

## Current Provenance Corridor

Primary browser-side latency metric corridor is:

- `public/js/agent-status-row.js`
- `PHASE63_SHARED_TASK_EVENTS_METRICS` block

This corridor owns:

- `metric-latency`
- task start-time capture
- terminal duration capture
- rolling duration sample retention
- latency formatting and null-state display

## Current Sampling Semantics

Observed browser-side logic indicates:

- start times are captured from running-task event types
- durations are captured only when a terminal event arrives
- duration = terminal event timestamp - first retained start timestamp
- samples are retained in a rolling in-memory buffer
- current sample cap is `50`

## Null-State Semantics

Before any completed duration sample exists:

- `metric-latency` displays `—`

## Audit Direction

Next narrow check:

- verify exactly which event types seed `taskStartTimes`
- verify exactly which terminal types contribute durations
- verify whether first-seen start time is intentionally retained across retries / re-runs
- verify whether current averaging semantics are acceptable from this baseline

## Rule

Audit only before implementation.

No layout mutation.
No ID changes.
No structural wrappers.
No producer mutation.
