# Phase 487 — task_events Restoration Source Audit

## Classification
SAFE — Read-only, bounded restoration-source audit

## Purpose
The runtime is now blocked by a concrete schema absence:

- `db/main.db` exists but is 0 bytes
- `task_events` is not present

Before any restoration mutation, identify the safest restoration source.

## Audit questions
1. Do backup SQLite files already contain `task_events`?
2. Does a seed or schema file define the required table?
3. Is the next move data restoration or schema bootstrap?

## Status
READY
