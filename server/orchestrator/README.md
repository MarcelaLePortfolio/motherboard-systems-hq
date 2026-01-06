# server/orchestrator (Phase 18+)

Phase 18 introduces a minimal, in-memory orchestration runtime:

- `phase18_store.mjs`: in-memory orchestrator store
- `phase18_tick.mjs`: minimal tick (optionally logs cadence)
- `phase18_orchestration.mjs`: interval loop + boot queue seed

Gate:
- `PHASE18_ENABLE_ORCHESTRATION=1`

Optional:
- `PHASE18_TICK_MS` (default 1000)
- `PHASE18_TICK_LOG_EVERY` (default 10)

Notes:
- No persistence in Phase 18.
- This is scaffolding for later phases: policies, agent reconciliation, queue processing, and SSE/UI exposure.
