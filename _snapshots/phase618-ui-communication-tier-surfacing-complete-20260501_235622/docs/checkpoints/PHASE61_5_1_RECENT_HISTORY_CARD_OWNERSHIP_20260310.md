# Phase 61.5.1 — Recent Tasks / Task History Card Ownership
Date: 2026-03-10

## Objective
Ensure Recent Tasks and Task History fully own their telemetry cards so legacy probe/log content cannot remain underneath new Phase 61 telemetry rendering.

## Problem Resolved
Recent Tasks was rendering its loading/status line into a reused surface that still contained older policy/probe content.

This was not a layout-contract issue.
It was a card-ownership issue.

## Fix Applied
The Recent Tasks / Task History wiring now:
- clears reused card content before mounting
- removes legacy empty/probe attributes
- mounts owned shell markup as the sole card content
- keeps refresh behavior intact
- preserves the locked Phase 61 structure

## Layout Safety
The layout contract remained green throughout:
- metrics row intact
- workspace shell intact
- workspace grid intact
- Operator Workspace intact
- Telemetry Workspace intact
- Atlas band still full width

## Files Changed
- `public/js/phase61_recent_history_wire.js`

## Relevant Commits
- `d93d6f78` — Phase 61.5.1: add Recent Tasks and Task History ownership patch
- `59d297fe` — Phase 61.5.1: let Recent Tasks and Task History fully own their telemetry cards

## Current Status
Phase 61 dashboard is now:
- structurally locked
- runtime recoverable
- Task Events wired
- Recent Tasks wired
- Task History wired
- Recent/History cards fully owned by their current telemetry renderers

## Rule Still In Force
Never fix forward.
If structural layout breaks:
1. restore checkpoint
2. verify layout contract
3. re-apply cleanly
