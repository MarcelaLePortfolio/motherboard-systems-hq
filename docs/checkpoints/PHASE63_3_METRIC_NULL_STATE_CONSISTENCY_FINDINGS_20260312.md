# PHASE 63.3 METRIC NULL-STATE CONSISTENCY FINDINGS
Date: 2026-03-12

## Summary

Initial Phase 63.3 null-state consistency findings captured from the verified Phase 63.2 golden baseline.

## Current Metric Null / Idle Semantics

Observed current tile behavior:

### Active Agents
- initial render uses `—`
- live count renders as numeric value
- SSE error path returns the metric to `—`

### Tasks Running
- idle render is numeric
- current idle state is `0`
- no placeholder state is used

### Success Rate
- renders `—` until at least one terminal event exists
- then renders rounded percentage from completed / (completed + failed)

### Latency
- renders `—` until at least one duration sample exists
- then renders formatted rolling average

## Consistency Assessment

Current null-state behavior is intentionally mixed rather than uniform:

- availability / connectivity-sensitive metric:
  - Active Agents → `—`
- count-style live occupancy metric:
  - Tasks Running → `0`
- outcome / duration metrics without history:
  - Success Rate → `—`
  - Latency → `—`

This is semantically coherent from the current baseline because:
- `0` communicates a valid empty running-set count
- `—` communicates unavailable / not-yet-known / no-history state

## Current Verdict

No immediate consumer refinement is required from this audit pass.

The present null-state model is interpretable and internally consistent enough to preserve.

## Next

Proceed to the next narrow Phase 63.3 telemetry audit target:

- verifier coverage gap for metric semantics versus presence-only checks

## Safety

No layout mutation.
No ID changes.
No structural wrappers.
No producer mutation.
