# Phase 682 — Coherence Source Clarity Ready

## Status

Implemented.

## Summary

Phase 682 clarifies coherence-shadow metadata so operators can distinguish memory history, persisted JSONL history, and merged coherence availability.

## Files Updated

- `server/routes/operator-guidance.mjs`

## Response Metadata Added

- `availability.memory`
- `availability.persisted`
- `availability.merged`
- `counts.memory_events`
- `counts.persisted_events`
- `counts.merged_events`
- `counts.coherent_events`

## Behavior Preserved

- Execution behavior unchanged.
- Worker behavior unchanged.
- SSE behavior unchanged.
- UI behavior unchanged.
- Formatting behavior unchanged.
- Database behavior unchanged.
- In-memory guidance history remains active.
- JSONL persistence remains active.
- Coherence remains derived-only and read-only.

## Validation Target

After rebuild:

- `/api/guidance/coherence-shadow` should return phase `682`.
- `availability.persisted` should reflect JSONL availability.
- `availability.memory` should reflect process-local history availability.
- `availability.merged` should reflect total coherence input availability.
- `counts` should expose source-specific event counts.
