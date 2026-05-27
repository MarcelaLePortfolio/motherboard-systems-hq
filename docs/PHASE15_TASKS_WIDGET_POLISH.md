# Phase 15 – Tasks Widget Polish

## Goal
Lock in confidence that the Tasks widget remains stable over time by adding
a fast, repeatable smoke check that can be run before demos, merges, or tags.

## What’s Already Stable
- No blinking / flicker
- Per-task completion state persists
- DB-backed tasks
- SSE wiring functional

## New Asset
`scripts/phase15_tasks_widget_smoke.sh`

This script verifies:
1. `/dashboard` loads successfully
2. `/api/tasks` returns a valid tasks array
3. `/events/tasks` advertises `text/event-stream`
4. SSE endpoint is reachable without blocking or crashing

## When to Run
- Before tagging a Phase 15 baseline
- After backend or SSE-related changes
- Before handoff or demo

## Usage
```bash
./scripts/phase15_tasks_widget_smoke.sh
A clean run indicates the Tasks widget is safe to build on.
