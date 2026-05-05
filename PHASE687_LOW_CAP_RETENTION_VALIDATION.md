# Phase 687 — Low-Cap Retention Validation

## Status

Validated.

## Test Method

A temporary Compose override set:

GUIDANCE_HISTORY_MAX_LINES=4

Guidance was primed and the JSONL file was inspected afterward.

## Confirmed Results

- `/api/guidance` returned valid JSON.
- `/app/data/guidance-history.jsonl` stayed capped at 4 lines.
- New guidance events were appended.
- Older events were trimmed.
- Newest retained timestamp advanced to `2026-05-05T03:30:29.716Z`.
- Coherence-shadow continued reading persisted events.
- `availability.memory` returned true after priming.
- `availability.persisted` returned true.
- `availability.merged` returned true.
- `counts.persisted_events` returned 4.
- `counts.merged_events` returned 4.
- `counts.coherent_events` returned 2.
- Runtime continued normally.

## Runtime Impact

- Execution unchanged
- Worker unchanged
- SSE unchanged
- UI unchanged
- Formatting unchanged
- Database unchanged

## Phase 687 Conclusion

Line-count retention works under a low-cap validation setting and safely preserves newest persisted guidance signals.

## Next Safe Corridor

Phase 688 — restore normal runtime cap and final persistence seal.

Goal:

Rebuild using the base Compose file only, confirm default retention config is restored, and seal the persistence/coherence durability corridor.
