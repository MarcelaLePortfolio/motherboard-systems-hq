# PHASE 63.1 CALCULATION PATH AUDIT STARTED
Date: 2026-03-12

## Objective

Continue Phase 63.1 by auditing the in-browser calculation paths behind the System Metrics tiles.

## Audit Focus

- duplicate EventSource usage
- event classification consistency
- terminal event semantics
- sample-window assumptions
- provisional vs canonical calculation paths

## Current Context

Initial source audit confirmed:

- Active Agents derives from `/events/ops`
- Tasks Running derives from `/events/task-events`
- Success Rate derives from `/events/task-events`
- Latency derives from `/events/task-events`

The remaining question is not whether they render, but whether their calculations are canonical, duplicated, or provisional.

## Rules

No layout mutation.
No ID changes.
No structural wrappers.
Audit first, normalize second.
