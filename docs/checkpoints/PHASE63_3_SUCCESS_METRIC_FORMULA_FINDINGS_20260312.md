# PHASE 63.3 SUCCESS METRIC FORMULA FINDINGS
Date: 2026-03-12

## Summary

Phase 63.3 success metric formula audit findings captured from the verified Phase 63.2 golden baseline.

## Verified Formula

Current browser-side success metric formula is:

completed / (completed + failed)

Rendered as:

rounded whole-number percentage

Code-path evidence confirms:

- `const total = completedCount + failedCount`
- `Math.round((completedCount / total) * 100)`

## Null-State Semantics

Before any terminal task event exists:

- `metric-success` displays `—`

This confirms null-state behavior is intentionally withheld until terminal-history exists.

## Event Inclusion Semantics

Success percentage is driven only by terminal task outcomes:

- completed
- failed

Running and non-terminal events are excluded from the percentage denominator.

## Dedupe Semantics

Terminal events are deduped using:

- `taskId`
- normalized `eventType`
- `eventTs`

Current dedupe key:

- `${taskId}|${eventType}|${eventTs}`

## Assessment

Current success metric semantics are internally coherent and acceptable from this audit pass:

- formula is correct
- null-state is correct
- running events do not contaminate success percentage
- terminal counting is dedupe-guarded

## Next

Proceed to the next narrow Phase 63.3 telemetry audit target:

- latency metric provenance and sampling semantics

## Safety

No layout mutation.
No ID changes.
No structural wrappers.
No producer mutation.
