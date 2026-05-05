# Phase 685 — Persistence Retention Design

## Status

Design only.

## Objective

Design a safe retention and rotation strategy for `/app/data/guidance-history.jsonl`.

## Current State

- Guidance history is persisted to JSONL.
- JSONL is stored on Docker named volume `guidance_data`.
- Persistence survives dashboard rebuilds.
- Coherence-shadow can read persisted events after memory reset.

## Retention Problem

The JSONL file can grow indefinitely if guidance is called repeatedly.

## Recommended Retention Strategy

Use line-count retention first.

## Recommended Default

Keep the most recent 1,000 guidance events.

## Why Line-Count Retention First

- Simple
- Deterministic
- Easy to validate
- No clock-skew edge cases
- No schema change required
- No execution coupling

## Proposed Future Adapter Behavior

After append:

1. Read file line count.
2. If line count <= max, do nothing.
3. If line count > max, keep only the newest max lines.
4. Rewrite the JSONL file atomically.

## Proposed Environment Variable

GUIDANCE_HISTORY_MAX_LINES=1000

## Atomic Rewrite Shape

1. Write retained lines to temporary file.
2. Rename temporary file over main JSONL file.

## Failure Mode

If retention fails:

- Log warning.
- Keep existing JSONL untouched.
- Do not interrupt `/api/guidance`.
- Do not interrupt SSE.
- Do not interrupt coherence-shadow.

## Non-Goals

- No time-window retention yet.
- No compression yet.
- No database migration.
- No UI change.
- No execution change.
- No scheduler activation.

## Validation Plan For Implementation Phase

1. Set a low max line value for validation.
2. Prime guidance multiple times.
3. Confirm JSONL is capped.
4. Confirm coherence-shadow still reads persisted events.
5. Confirm no execution behavior changes.

## Next Safe Corridor

Phase 686 — implement line-count retention in the JSONL guidance history adapter.
