# Phase 35 — Lease Epoch + Owner Enforcement on Terminal Writes

## Objective
Prevent stale workers from writing terminal outcomes after a reclaim.

### Required enforcement
- `mark_success` / `mark_failure` MUST only succeed when:
  - `tasks.claimed_by` matches the worker owner attempting the write
  - `tasks.lease_epoch` matches the epoch value observed at claim time
- Any attempt by a stale worker (wrong owner or wrong epoch) MUST be a no-op:
  - no status change
  - no terminal event emitted
  - no duplicate terminal writes

## Semantics
- `lease_epoch` is a monotonic integer on `tasks`.
- Claiming a task captures `(claimed_by, lease_epoch)` as the worker's claim token.
- Reclaim MUST bump `lease_epoch` when it resets a running task back to created/unclaimed.

## Smoke proof
Extend a single smoke proof demonstrating:
- reclaim invalidates stale workers
- only the fresh claimant can write the terminal state
- exactly one terminal event is emitted
