# Phase 689 — Coherence Persistence UI Ready

## Status

Implemented.

## Summary

Phase 689 exposes persistence metadata inside the existing read-only Coherence Preview.

## Files Updated

- `app/components/GuidancePanel.tsx`

## UI Fields Added

- Memory available
- Persisted available
- Merged available
- Memory events
- Persisted events
- Merged events
- Persistence source
- Persistence enabled

## Behavior Preserved

- Execution unchanged
- Worker unchanged
- SSE unchanged
- Guidance API unchanged
- Coherence API unchanged
- Formatting unchanged
- Database unchanged
- No mutation paths added
- UI remains read-only

## Validation Target

After rebuild:

- Coherence Preview should show persistence metadata.
- `/api/guidance/coherence-shadow` should remain unchanged.
- Dashboard should render without errors.
