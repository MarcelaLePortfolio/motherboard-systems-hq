# Phase 25 — Single Writer Declaration

Branch: feature/phase24-orchestration-polish
Contract: PHASE25_AUTHORITY_ORCHESTRATION_CONTRACT.md

Chosen Single Writer (must be the ONLY component allowed to mutate task lifecycle):
- server/task-events.mjs

All files that appear to write to task_events (audit list):
- server/task-events.mjs
