# Phase 663 — Guidance History Design

Status: DESIGN ONLY

Goal:
Introduce a lightweight, read-only, in-memory guidance history buffer.

Rules:
- No DB writes
- No execution coupling
- No task mutation
- No scheduler mutation
- Backward compatible API/SSE behavior only

Initial design:
- Capture guidance snapshots emitted by the existing guidance layer
- Store recent snapshots in memory only
- Preserve current /api/guidance response shape
- Prepare future UI timeline consumption without enabling it yet

Validation:
- /api/guidance still works
- /events/guidance still streams
- Execution pipeline remains untouched
