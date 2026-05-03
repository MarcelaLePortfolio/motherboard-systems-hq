# PHASE 63.1 SHARED TASK EVENTS METRIC CORRIDOR NORMALIZED
Date: 2026-03-12

## Summary

This checkpoint normalizes the task-events-backed metric corridor by replacing three separate browser-side EventSource consumers with one shared consumer and one unified event classification model.

## Changes Applied

Removed separate browser-side metric blocks for:

- Tasks Running hydration
- Success Rate hydration
- Latency hydration

Replaced with one shared browser-side corridor that:

- opens one `/events/task-events` EventSource
- uses one shared event classifier
- maintains one shared task state model
- renders:
  - Tasks Running
  - Success Rate
  - Latency

## Canonicalized Event Semantics

Running/start corridor:

- `created`
- `queued`
- `leased`
- `started`
- `running`
- `in_progress`
- `delegated`
- `retrying`

Terminal success corridor:

- `completed`
- `complete`
- `done`
- `success`

Terminal failure corridor:

- `failed`
- `error`
- `cancelled`
- `canceled`
- `timed_out`
- `timeout`
- `terminated`
- `aborted`

## Result

This removes the earlier semantic mismatch where one metric could consider a task terminal while another still considered it running.

## Safety

No layout mutation.
No ID changes.
No structural wrappers.
Phase 62.2 layout contract remains protected.
Phase 62B metric binding contract remains protected.
