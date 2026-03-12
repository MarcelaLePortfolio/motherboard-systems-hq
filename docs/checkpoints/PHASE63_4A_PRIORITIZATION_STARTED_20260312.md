# PHASE 63.4A PRIORITIZATION STARTED
Date: 2026-03-12

## Summary

Phase 63.4A now advances from candidate discovery into a narrow prioritization pass.

## Objective

Identify which documented static verifier candidate is safest to promote later into a separate implementation subphase.

## Prioritization Criteria

A candidate is preferred if it is:

- deterministic
- file-based
- structure-adjacent
- low-risk
- non-runtime
- non-networked
- unlikely to overfit
- unlikely to block valid future telemetry work

## Current Candidate Set

- metric tile ID uniqueness
- metric tile label presence
- telemetry anchor marker presence
- duplicate container detection
- SSE anchor presence (static only)
- forbidden wrapper detection

## Rule

Prioritization only.

No implementation.
No JS mutation.
No layout mutation.
No verifier mutation.

## Next

Record a ranked recommendation for future verifier promotion.
