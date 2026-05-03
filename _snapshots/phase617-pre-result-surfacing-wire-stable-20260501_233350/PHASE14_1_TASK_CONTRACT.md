# Phase 14.1 — Task lifecycle contract

## Required fields
- id (string)
- title (string)
- agent (string)
- status (enum)
- created_at (ISO)
- updated_at (ISO)

## Optional fields
- notes
- source
- trace_id
- error
- meta

## Status enum
queued | delegated | running | blocked | complete | canceled | failed

## Allowed transitions
- queued → delegated
- delegated → running
- running → complete
- running → blocked
- blocked → running
- queued/delegated/running/blocked → canceled
- queued/delegated/running/blocked → failed

## Forbidden
- complete → *
- canceled → *
- failed → *
- any regression

## API rules
- validate inputs
- normalize id to string
- timestamps set server-side
- enforce transitions

## UI rules
- never render undefined
- updated_at preferred, fallback created_at

## SSE rules
Emit only meaningful changes with canonical task payload.
