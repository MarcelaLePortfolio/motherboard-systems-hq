# Phase 37.4 — Terminal Event Integrity Gaps (Planning Only)

## Trigger
Acceptance lens reports: tasks.status terminal but no terminal task_events row.

## Goal (planning)
Identify the source of divergence and define a minimal, contract-safe remedy.

## Non-goals
- No schema/view changes without a new phase decision record
- No worker behavior change in this phase (planning-only first)

## Evidence
See acceptance.out, run_ids.txt, and per-run snapshots in this folder.
