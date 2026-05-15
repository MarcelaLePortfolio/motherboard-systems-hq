
# PHASE 719 — STALE PHASE530 CALLS STILL ACTIVE

## OBSERVATION

Even after cache-busted reload, the browser still calls:

- `/api/agents`

- `/api/activity-graph`

## CLASSIFICATION

This is not resolved by browser cache busting.

The active served `phase530_visible_panels_bridge.js` still contains executable stale fetch paths or an equivalent active code path.

## NEXT STEP

Inspect the exact live local and served code around lines 650–695 before applying another mutation.

