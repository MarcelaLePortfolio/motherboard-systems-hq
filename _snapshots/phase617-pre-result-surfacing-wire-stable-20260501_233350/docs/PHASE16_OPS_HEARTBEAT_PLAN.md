# Phase 16 – OPS / Tasks Heartbeat & Failure Surfacing

## Objective
Unify system confidence signals by exposing a shared heartbeat and
lightweight failure indicators across OPS and Tasks.

## Phase 15 Baseline
- Tag: v15.2-phase15-polish-complete
- Tasks widget: stable, DB-backed, smoke-tested

## Phase 16 Scope (High ROI)
1. Shared heartbeat timestamp (OPS + Tasks)
2. Visible stale-state detection (no silent failures)
3. Minimal UI surfacing (badge or toast, non-intrusive)

## Non-Goals
- No new agent logic
- No UI redesign
- No blocking flows

## First Deliverable
Expose a normalized heartbeat source consumable by:
- OPS pill
- Tasks widget (read-only)

