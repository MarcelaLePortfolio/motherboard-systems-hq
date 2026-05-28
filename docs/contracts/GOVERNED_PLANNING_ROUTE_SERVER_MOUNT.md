
# Governed Planning Route Server Mount

## Status

The governed planning dry-run route is now mounted in `server.mjs`.

## Mounted Route

`server/routes/governed-planning-route.mjs`

## Route Surface

`POST /api/governed-planning/dry-run`

## Boundary Preserved

This mount exposes only the governed planning dry-run route.

It does not authorize:

- filesystem mutation

- shell execution

- autonomous execution

- PM2 mutation

- recursive delegation

- legacy run_shell promotion

## Architectural Meaning

The active server now has a registered HTTP surface for the canonical governed planning pipeline.

The route remains planning-only, reconciliation-ready, audit-ready, and fail-closed.

