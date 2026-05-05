# Phase 680 — JSONL Guidance History Adapter Ready

## Status

Implemented.

## Summary

Phase 680 introduces a durable JSONL guidance history adapter while preserving the existing in-memory guidance history path.

## Files Added

- `server/guidance/guidance-history-store.mjs`

## Files Updated

- `server/routes/operator-guidance.mjs`

## Behavior

- `/api/guidance` still builds guidance normally.
- Existing in-memory history remains active.
- Flattened guidance events are appended to `data/guidance-history.jsonl`.
- `/api/guidance/coherence-shadow` reads recent persisted events and merges them with in-memory events.
- Coherence remains derived-only and read-only.

## Runtime Impact

- Execution: false
- SSE: false
- UI: false
- Formatting: false
- Database: false

## Failure Mode

If JSONL persistence fails:

- Warning is logged.
- In-memory guidance history continues.
- Runtime is not interrupted.

## Coherence Response Additions

- `phase: "680"`
- `source`
- `persistence.enabled`
- `persistence.source`
- `persistence.event_count`
- `persistence.error`

## Validation Target

After rebuild, call:

- `/api/guidance`
- `/api/guidance-history`
- `/api/guidance/coherence-shadow`

Expected result:

- Guidance still returns normally.
- In-memory history remains populated.
- Coherence-shadow includes persisted event metadata.
- No execution behavior changes.
