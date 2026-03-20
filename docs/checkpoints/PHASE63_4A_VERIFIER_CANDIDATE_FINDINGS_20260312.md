# PHASE 63.4A VERIFIER CANDIDATE FINDINGS
Date: 2026-03-12

## Summary

Initial Phase 63.4A static semantic verifier candidate audit findings captured from the verified Phase 63.4 baseline.

## Current Protected Coverage

Existing protected verification remains strongest in:

- layout structure
- key container presence
- metric tile anchor presence
- ordering invariants for major dashboard regions

## Candidate Static Verifier Additions

Safe deterministic candidates identified:

### Candidate 1 — Metric tile ID uniqueness
Verify each metric tile ID appears exactly once:

- `metric-agents`
- `metric-tasks`
- `metric-success`
- `metric-latency`

### Candidate 2 — Metric tile label presence
Verify the compact telemetry tiles still expose expected labels or semantic markers for:

- Active Agents
- Tasks Running
- Success Rate
- Latency

### Candidate 3 — Telemetry anchor marker presence
Verify the Phase 62B metric binding marker remains present.

### Candidate 4 — Duplicate container detection
Extend protection by checking unique count for existing protected containers and rejecting accidental duplicate dashboard regions.

### Candidate 5 — SSE anchor presence (static only)
Verify task-events anchor/container marker presence only where intentionally required by the protected dashboard structure.

### Candidate 6 — Forbidden wrapper detection
Consider narrow rejection checks for known-unwanted structural wrappers if they can be expressed deterministically without overfitting.

## Assessment

The safest future verifier promotions remain:

- file-based
- deterministic
- structure-adjacent
- non-runtime
- non-networked

Still not appropriate for verifier promotion at this step:

- live semantic checks
- timing-based checks
- SSE delivery checks
- browser-executed telemetry calculations

## Decision

Phase 63.4A has now identified a narrow set of candidate static checks that could later be promoted without destabilizing the protected baseline.

No implementation performed in this step.

## Safety

No layout mutation.
No JS mutation.
No verifier mutation.
No producer mutation.
