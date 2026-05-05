# Phase 678 — Persistence-Aware Coherence Inspection

## Status

Inspection complete.

## Confirmed Findings

- Active guidance history route is `/api/guidance-history`.
- `/api/guidance/history` is not mounted and returns 404.
- Active coherence route is `/api/guidance/coherence-shadow`.
- Coherence-shadow source is `express-guidance-history`.
- Guidance history is currently stored in process memory through `guidanceHistory` in `server/routes/operator-guidance.mjs`.
- History is capped at 50 snapshots.
- History is lost on container restart.
- No durable JSONL guidance persistence is currently active for this layer.
- Coherence aggregation is derived only and does not mutate execution, SSE, UI, formatting, or database state.

## Current Coherence Flow

1. `/api/guidance` builds guidance from recent task state.
2. `recordGuidanceHistory(payload)` stores the snapshot in memory.
3. `/api/guidance-history` exposes the in-memory snapshot list.
4. `/api/guidance/coherence-shadow` flattens in-memory history.
5. `deriveCoherentGuidance(raw)` prepares the raw events.
6. `coherence-engine.mjs` groups, deduplicates, counts, and normalizes derived guidance.

## Current Coherence Identity Key

task_id::subsystem::signal_type

## Current Derived Fields

- first_seen
- last_seen
- count
- normalized_severity
- consistency_flag

## Current Severity Behavior

- Repeated warning signals with count >= 3 become elevated.
- Repeated signals with count >= 5 become critical.
- Existing critical signals remain critical.

## Persistence Gap

The handoff expected JSONL persistence, but inspection confirms the active runtime path is in-memory only.

## Safe Phase 678 Conclusion

Persistence-aware coherence should not be implemented yet until the durable history shape is designed.

## Recommended Next Corridor

Phase 679 should be a design-only pass for durable guidance history.

## Phase 679 Design Questions

1. Should durable guidance history be JSONL, database-backed, or both?
2. Should persistence store full guidance snapshots or already-flattened signal events?
3. Should persistence happen inside `recordGuidanceHistory`, beside it, or behind a new storage adapter?
4. Should persisted history survive restarts but remain capped by time/count?
5. Should coherence read from memory first, durable history second, or a merged source?
6. Should the UI expose persistence source state separately from coherence source state?

## Non-Goals

- No execution mutation.
- No database schema mutation.
- No scheduler activation.
- No system-led execution activation.
- No change to worker lifecycle.
- No change to retry behavior.
- No change to existing UI behavior.

## Recommended Safe Implementation Shape Later

Introduce a storage adapter only after design approval:

server/guidance/guidance-history-store.mjs

Potential adapter responsibilities:

- append guidance snapshot
- read recent snapshots
- cap retained history
- normalize timestamps
- report storage source
- fail closed to in-memory history if durable storage is unavailable

## Final Phase 678 State

Phase 678 confirms that coherence aggregation is working, but it is not persistence-aware yet.
