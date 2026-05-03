# Phase 16 — v16.1 ops/reflections singleton SSE (STABLE TAG)

**Stable tag:** `v16.1-phase16-ops-reflections-singleton-ok`

## Goal (what we fixed)
Eliminate the dashboard crash:
- `Uncaught TypeError: Cannot set properties of null (setting 'onopen')`

Root cause was Phase16 “owner” mode causing bundle codepaths to return `null` / create `null` EventSource and still attempt `es.onopen = ...`.

## What’s now true
- `/dashboard` serves the correct dashboard HTML (distinct from `/`).
- Owner script creates singleton connections:
  - `window.__opsES = new EventSource("/events/ops")`
  - `window.__refES = new EventSource("/events/reflections")`
- Bundle code now **reuses** owner singletons instead of returning `null`:
  - connect() binds to `window.__opsES` / `window.__refES` when owner started
  - remaining “owner-started null ES” ternaries removed for OPS
  - generic early-return that blocked wiring in owner mode removed
- SSE endpoints confirmed 200 with `Content-Type: text/event-stream`.

## Key files touched
- `public/js/phase16_sse_owner_ops_reflections.js`
  - Adds DOMContentLoaded guard + dashboard-presence guard
  - Creates singleton EventSource objects on `window`
- `public/bundle.js`
  - connect() reworked to reuse owner ES instead of returning null
  - OPS status row + ops-globals-bridge updated to reuse owner ES
  - indentation normalized (cosmetic)

## Quick runtime probe (paste in /dashboard devtools console)
({
  started: window.__PHASE16_SSE_OWNER_STARTED,
  ownerReady: window.__PHASE16_SSE_OWNER_READY,
  opsES: !!window.__opsES,
  opsReadyState: window.__opsES && window.__opsES.readyState,
  refES: !!window.__refES,
  refReadyState: window.__refES && window.__refES.readyState,
  lastOpsHeartbeat: window.lastOpsHeartbeat,
  lastOpsStatusSnapshot: window.lastOpsStatusSnapshot,
})

Expected:
- started: true
- opsES/refES: true
- readyState: 0 or 1 (connecting/open)

## Next highest-ROI work
1) Confirm reflections stream behavior in UI (indicator state updates + no console errors).
2) If reflections is not being consumed anywhere yet, wire reflections->UI status panel using the same pattern as OPS.
3) Optionally: rebuild bundle from source (if Phase16 scripts exist in /public/js) to avoid future manual bundle edits.
