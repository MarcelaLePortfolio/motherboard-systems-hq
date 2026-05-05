# Phase 698 — Snapshot Comparison (Read-Only Diff) Ready

## Status

Implemented.

## Summary

Phase 698 introduces a read-only snapshot comparison feature, allowing operators to diff two exported coherence snapshots directly in the UI.

## Files Updated

- `app/components/GuidancePanel.tsx`

## Feature Added

### Snapshot Comparison (Client-Side Only)

- Allows selection of two snapshots from "Recent Snapshots"
- Computes a read-only diff between snapshots
- No backend interaction
- No mutation paths

## Diff Coverage

### 1. Counts Diff

- persisted_events delta
- memory_events delta
- merged_events delta
- coherent_events delta

### 2. Availability Diff

- memory availability change
- persisted availability change
- merged availability change

### 3. Signal Diff

- Newly introduced signals
- Removed signals
- Persisting signals (unchanged)

### 4. Stability Diff

- Collapse ratio change
- Stability classification change (Stable / Moderate / Volatile)

## UX Details

- New section: "Snapshot Comparison"
- Two dropdowns:
  - Select Snapshot A
  - Select Snapshot B
- Displays:
  - Numeric deltas (↑ ↓ indicators)
  - Highlighted differences
- Non-blocking, inline rendering

## Data Scope

- Uses in-memory snapshot history
- No persistence beyond session
- No localStorage

## Behavior Preserved

- Execution unchanged
- Worker unchanged
- SSE unchanged
- Guidance API unchanged
- Coherence API unchanged
- Formatting unchanged
- Database unchanged

## Validation Target

After rebuild:

- Snapshot comparison UI renders correctly
- Selecting two snapshots produces valid diff
- Deltas display accurately
- No UI or console errors
- No regression in existing features

## Phase 698 Goal

Provide operators with lightweight comparative insight while maintaining strict read-only and non-invasive guarantees.
