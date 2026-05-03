# Phase 487 — task_events Table Audit

## Classification
SAFE — Read-only, bounded schema audit

## Purpose
The runtime now gets past package and native-binding blockers and fails on a concrete database schema issue:

- `no such table: task_events`

Before any mutation, this step verifies:

1. which SQLite file `db/client.ts` is targeting
2. whether that database file exists
3. whether the `task_events` table exists there
4. whether the next move should be schema restoration rather than runtime/package work

## Status
READY
