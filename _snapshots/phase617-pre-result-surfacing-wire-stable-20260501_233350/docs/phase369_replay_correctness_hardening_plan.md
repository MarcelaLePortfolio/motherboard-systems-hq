# Phase 369 — Replay Correctness Hardening Plan

## Objective
Harden the governance investigation corridor by defining deterministic replay correctness guarantees before any dashboard wiring or operator-facing integration.

## Why this phase
Phases 365–368 established the investigation foundation:
- investigation types
- timeline modeling
- playback model
- navigation assembly

The next safe move is not more surface area. The next safe move is correctness.

## Primary outcome
Establish an explicit replay correctness contract for governance investigation so that all future operator investigation surfaces are constrained by deterministic, testable rules.

## Scope
This phase should define and harden:

1. Replay invariants
- replay is read-only
- replay is derived from source trace only
- replay cannot synthesize missing authority
- replay cannot mutate decision history
- replay ordering is deterministic
- replay cursor movement is bounded
- replay state is reproducible from the same source trace
- replay outputs are explanation-compatible
- replay does not introduce execution authority
- replay does not alter audit provenance

2. Navigation boundary guarantees
- valid cursor entry conditions
- valid step-forward behavior
- valid step-back behavior
- boundary behavior at start/end of timeline
- deterministic handling of empty traces
- deterministic handling of partial traces
- deterministic handling of unknown event categories

3. Assembly correctness guarantees
- assembly must preserve trace ordering guarantees
- assembly must preserve source identifiers
- assembly must preserve explanation linkage
- assembly must preserve audit linkage
- assembly must reject structurally invalid replay input
- assembly output must be stable for equivalent source traces

4. Validation direction
- deterministic replay test matrix
- fixture shape expectations
- invalid trace rejection expectations
- boundary-case expectations
- replay/idempotence expectations

## Explicit non-scope
Do not introduce:
- dashboard integration
- runtime mutation
- worker wiring
- reducer expansion outside replay correctness
- execution path integration
- routing authority
- task mutation
- agent mutation
- speculative UX expansion

## Recommended deliverables
1. docs/governance_replay_correctness_contract.md
2. docs/governance_replay_invariants.md
3. docs/governance_replay_navigation_boundaries.md
4. docs/governance_replay_validation_matrix.md

## Engineering posture
- smallest safe change
- documentation + constraint first
- no fix-forward behavior
- compile before commit if code is touched
- protect deterministic boundaries before adding surfaces

## Exit criteria
Phase 369 is complete when:
- replay invariants are explicitly documented
- navigation boundary behavior is unambiguous
- assembly correctness expectations are explicit
- future validation targets are defined
- next implementation work is narrowed to deterministic proof, not reinterpretation

## Recommended next phase after completion
Phase 370 should convert the correctness contract into focused validation scaffolding and replay proof coverage.

## Resume line
Motherboard Systems HQ continuation
Phase 369
Replay correctness hardening
Deterministic investigation corridor
No dashboard wiring yet
