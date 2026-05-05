# Phase 690 — Operator Affordances Ready

## Status

Implemented.

## Summary

Phase 690 introduces optional, read-only operator affordances to enhance visibility into persistence vs memory behavior and signal stability.

## Files Updated

- `app/components/GuidancePanel.tsx`

## UI Enhancements Added

### 1. Persistence Source Indicator

Displays dominant source:

- "Memory-dominant"
- "Persisted-dominant"
- "Balanced"

Derived from:

- `counts.memory_events`
- `counts.persisted_events`

### 2. Signal Stability Indicator

Displays stability classification:

- Stable (high coherence collapse)
- Moderate
- Volatile (low collapse)

Derived from:

- coherence collapse ratio

### 3. Divergence Indicator

Displays passive alert when:

- `availability.memory !== availability.persisted`
OR
- significant delta between memory and persisted counts

Message example:

"Persistence divergence detected — memory and persisted signals differ."

## Behavior Preserved

- Execution unchanged
- Worker unchanged
- SSE unchanged
- Guidance API unchanged
- Coherence API unchanged
- Formatting unchanged
- Database unchanged
- No mutation paths introduced
- UI remains read-only

## Validation Target

After rebuild:

- UI renders without errors
- Indicators appear correctly based on live coherence data
- No impact to existing functionality

## Phase 690 Goal

Enhance operator awareness without introducing system risk or behavioral change.
