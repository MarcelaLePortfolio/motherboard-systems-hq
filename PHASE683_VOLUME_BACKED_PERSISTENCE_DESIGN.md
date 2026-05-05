# Phase 683 — Volume-Backed Persistence Design

## Status

Design only.

## Problem

Phase 682 confirmed that JSONL guidance history survives dashboard process restart, but not full container rebuild.

## Root Cause

`data/guidance-history.jsonl` currently lives inside the dashboard container filesystem.

A container restart preserves it.

A rebuild recreates the container filesystem and clears it.

## Goal

Make guidance JSONL persistence rebuild-resilient without changing execution behavior.

## Recommended Approach

Use a Docker named volume mounted at:

/app/data

## Why Named Volume

- Survives container rebuilds.
- Avoids host-path permission drift.
- Keeps runtime path unchanged.
- Requires no application code change.
- Preserves current `data/guidance-history.jsonl` location inside container.

## Proposed Compose Shape

Add a named volume:

guidance_data:

Mount it into the dashboard service:

- guidance_data:/app/data

## Expected Runtime Effect

The application continues writing to:

data/guidance-history.jsonl

Inside the container this resolves to:

/app/data/guidance-history.jsonl

But the data is stored in Docker-managed persistent volume storage.

## Safety Profile

- Execution pipeline: unchanged
- Worker: unchanged
- SSE: unchanged
- UI: unchanged
- Formatting: unchanged
- Database: unchanged
- Guidance code: unchanged
- Coherence code: unchanged

## Validation Plan

1. Rebuild containers.
2. Prime `/api/guidance`.
3. Confirm JSONL exists in `/app/data`.
4. Rebuild containers again.
5. Confirm JSONL still exists.
6. Confirm `/api/guidance/coherence-shadow` reports persisted availability.

## Non-Goals

- No database persistence.
- No schema changes.
- No rotation implementation.
- No retention policy implementation.
- No UI changes.
- No execution changes.

## Next Safe Corridor

Phase 684 — add Docker named volume for dashboard guidance data.
