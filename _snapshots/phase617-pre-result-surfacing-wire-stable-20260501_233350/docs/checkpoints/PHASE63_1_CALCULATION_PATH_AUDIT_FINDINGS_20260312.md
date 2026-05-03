# PHASE 63.1 CALCULATION PATH AUDIT FINDINGS
Date: 2026-03-12

## Summary

The current System Metrics telemetry remains stable, but the in-browser calculation layer is still provisional rather than canonical.

## Findings

### 1. Duplicate task-events subscriptions exist

Current implementation opens three separate browser-side EventSource connections to:

- `/events/task-events` for Tasks Running
- `/events/task-events` for Success Rate
- `/events/task-events` for Latency

This means Phase 63 currently computes three metrics from three parallel stream consumers rather than one normalized telemetry path.

### 2. Event classification is not yet unified

Tasks Running uses:

- running types:
  - `created`
  - `queued`
  - `leased`
  - `started`
  - `running`
  - `in_progress`
  - `delegated`
  - `retrying`

- terminal types:
  - `completed`
  - `failed`
  - `cancelled`
  - `canceled`
  - `timed_out`
  - `timeout`
  - `terminated`
  - `aborted`

Success Rate uses:

- success terminal types:
  - `completed`
  - `complete`
  - `done`
  - `success`

- failure terminal types:
  - `failed`
  - `error`
  - `cancelled`
  - `canceled`
  - `timed_out`
  - `timeout`
  - `terminated`
  - `aborted`

Latency uses:

- start types:
  - `created`
  - `queued`
  - `leased`
  - `started`
  - `running`
  - `in_progress`
  - `delegated`
  - `retrying`

- terminal types:
  - `completed`
  - `complete`
  - `done`
  - `success`
  - `failed`
  - `error`
  - `cancelled`
  - `canceled`
  - `timed_out`
  - `timeout`
  - `terminated`
  - `aborted`

### 3. Semantic mismatch exists across metrics

Observed mismatch:

- Tasks Running does not treat `complete`, `done`, `success`, or `error` as terminal
- Success Rate and Latency do treat those as terminal

This means one task could be considered terminal for one metric while still remaining "running" for another metric.

### 4. Sample model remains browser-local

Current browser-side state includes:

- `runningTaskIds`
- `completedCount`
- `failedCount`
- `taskStartTimes`
- `recentDurationsMs`

These values are page-session scoped and therefore provisional.

## Assessment

Phase 63.1 should normalize calculation semantics before any richer telemetry expansion.

## Recommended Next Step

Normalize the task-events metric corridor by introducing:

- one shared `/events/task-events` consumer
- one canonical event classification map
- one shared metric state model for:
  - running
  - terminal success
  - terminal failure
  - latency sampling

No layout changes required.
