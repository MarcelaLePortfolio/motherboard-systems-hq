# Phase 61.4 — Wiring Next
Date: 2026-03-10

## Clarification
Phase 61.3 was a presentation-only pass.

It did not introduce new backend wiring, stream plumbing, or render-path changes.
It only polished the visible Task Events panel inside the locked layout contract.

## What This Means
If little or no visible difference is apparent, that is consistent with the implementation.
The current patch depends on the existing DOM/event text shape and does not change the underlying event production path.

## Correct Next Step
Move from cosmetic post-render polish to real Task Events wiring.

### Target
Preserve locked layout structure while improving the actual Task Events render path.

### Scope
- do not change workspace structure
- do not change atlas placement
- do not fix forward if structure breaks
- only touch event rendering / telemetry behavior

### Wiring Goals
1. Find the code path that renders Task Events rows
2. Normalize event fields at render time
3. Apply lifecycle classes at render time
4. Improve scanability without relying on DOM rewrite after paint
5. Keep the layout verifier green at all times

## Rule
Never fix forward.
Restore first if structure breaks.
