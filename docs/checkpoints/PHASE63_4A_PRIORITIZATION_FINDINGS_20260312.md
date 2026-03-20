# PHASE 63.4A PRIORITIZATION FINDINGS
Date: 2026-03-12

## Summary

Phase 63.4A prioritization pass is complete.

A narrow ranking was applied to the documented static verifier candidates using the agreed criteria:

- deterministic
- file-based
- structure-adjacent
- low-risk
- non-runtime
- non-networked
- unlikely to overfit
- unlikely to block valid future telemetry work

## Ranked Recommendation

### Priority 1 — Metric tile ID uniqueness
Safest immediate future promotion candidate.

Why:
- purely static
- low ambiguity
- directly protects the four telemetry tiles
- low risk of blocking intended future telemetry behavior

Targets:
- `metric-agents`
- `metric-tasks`
- `metric-success`
- `metric-latency`

### Priority 2 — Telemetry anchor marker presence
Safe follow-on candidate.

Why:
- already conceptually aligned with current protected Phase 62B binding checks
- static and deterministic
- low risk of overreach

### Priority 3 — Duplicate container detection
Useful but slightly broader.

Why:
- still static and deterministic
- strengthens protection against silent structural duplication
- should remain tightly scoped to known protected containers only

### Priority 4 — Metric tile label presence
Potentially safe, but slightly more brittle.

Why:
- label copy can evolve
- more vulnerable to false failures if wording changes without structural regression

### Priority 5 — SSE anchor presence (static only)
Lower priority.

Why:
- safe only if scoped to intentional anchor requirements
- can become brittle if panel mounting strategy evolves

### Priority 6 — Forbidden wrapper detection
Lowest priority.

Why:
- highest overfit risk
- hardest to define cleanly without accidentally constraining valid future work

## Decision

Recommended future implementation order:

1. metric tile ID uniqueness
2. telemetry anchor marker presence
3. duplicate container detection

Phase 63.4A remains audit-only in this step.

No implementation performed.

## Safety

No layout mutation.
No JS mutation.
No verifier mutation.
No producer mutation.
