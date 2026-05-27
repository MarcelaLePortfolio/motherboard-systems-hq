# PHASE 63.3 LATENCY SAMPLING SEMANTICS FINDINGS
Date: 2026-03-12

## Summary

Narrow Phase 63.3 latency sampling semantics were verified from the current browser-side telemetry corridor.

## Verified Event Seeding

`taskStartTimes` is seeded only by normalized running-state event types:

- `created`
- `queued`
- `leased`
- `started`
- `running`
- `in_progress`
- `delegated`
- `retrying`

The first observed running-state timestamp is retained for a task until terminal resolution.

## Verified Terminal Contribution

Latency samples are contributed only by normalized terminal event types.

Success-side terminal contributors:

- `completed`
- `complete`
- `done`
- `success`

Failure-side terminal contributors:

- `failed`
- `error`
- `cancelled`
- `canceled`
- `timed_out`
- `timeout`
- `terminated`
- `aborted`

## Sampling Formula

Current latency sample formula is:

- `duration = terminal event timestamp - first retained start timestamp`

Current rolling sample retention:

- in-memory only
- capped at `50` most recent durations

Current null-state behavior:

- `metric-latency = —` before any duration sample exists

## Assessment

Current latency semantics are internally coherent for this audit pass:

- running events seed start time
- terminal events alone contribute durations
- first-seen start time is preserved until task termination
- rolling average is bounded and deterministic at the browser level

## Next

Proceed to the next narrow Phase 63.3 telemetry audit target:

- task running metric provenance and idle/null semantics

## Safety

No layout mutation.
No ID changes.
No structural wrappers.
No producer mutation.
