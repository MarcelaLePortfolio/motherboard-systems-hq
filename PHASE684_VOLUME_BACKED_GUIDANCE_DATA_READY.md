# Phase 684 — Volume-Backed Guidance Data Ready

## Status

Implemented.

## Summary

Phase 684 adds a Docker named volume for dashboard guidance data.

## Files Updated

- `docker-compose.yml`

## Volume Added

- `guidance_data`

## Mount Added

Dashboard service:

- `guidance_data:/app/data`

## Purpose

Make `data/guidance-history.jsonl` rebuild-resilient by storing it in a Docker-managed named volume.

## Runtime Behavior Preserved

- Execution unchanged
- Worker unchanged
- Postgres unchanged
- SSE unchanged
- UI unchanged
- Formatting unchanged
- Application guidance code unchanged
- Coherence code unchanged

## Validation Required

1. Rebuild containers.
2. Prime `/api/guidance`.
3. Confirm `/app/data/guidance-history.jsonl` exists.
4. Rebuild containers again.
5. Confirm `/app/data/guidance-history.jsonl` still exists.
6. Confirm coherence-shadow reports persisted availability.
