# PHASE 63.2 AGENT FRESHNESS INTERPRETATION REFINED
Date: 2026-03-12

## Summary

Phase 63.2 refined browser-side agent activity interpretation without changing producer shape.

## Producer Truth

Canonical freshness field remains:

- `globalThis.__OPS_STATE.agents[agent].at`

No producer mutation was required.

## Consumer Refinement

Updated:

- `public/js/agent-status-row.js`

Behavior now distinguishes:

- active = signal age <= 60s
- stale = signal age > 60s
- unknown = no signal

Additional behavior:

- per-agent rows now surface recency text
- active-agent metric still uses the existing 60s window
- row interpretation refreshes on an interval so active can decay into stale without requiring a new event
- SSE error clears freshness state and returns metric display to `—`

## Safety

No layout mutation.
No ID changes.
No structural wrappers.
No producer payload changes.
