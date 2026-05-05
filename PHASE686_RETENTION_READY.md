# Phase 686 — Guidance History Retention Ready

## Status

Implemented.

## Summary

Phase 686 adds line-count retention to the JSONL guidance history adapter.

## Files Updated

- `server/guidance/guidance-history-store.mjs`

## Behavior Added

- Retention runs after JSONL append.
- Retention keeps the newest `GUIDANCE_HISTORY_MAX_LINES` lines.
- Default max line count is `1000`.
- Retention uses atomic temp-file rewrite and rename.
- If retention fails, guidance runtime continues.

## Environment Variable Added

- `GUIDANCE_HISTORY_MAX_LINES`

## Runtime Behavior Preserved

- Execution unchanged
- Worker unchanged
- SSE unchanged
- UI unchanged
- Formatting unchanged
- Database unchanged
- Coherence remains read-only
- JSONL remains volume-backed

## Validation Target

Use a low temporary max line count in a later validation pass, then prime guidance repeatedly and confirm the file is capped.
