# ADR — Behavioral Reconstruction from Durable Repository Evidence

Date: 2026-08-05

Status: Verified Architectural Finding

## Summary

Repository inspection during Behavioral Integration — Corridor 2 (Unresolved History Policy) verified that behavioral decisions are reconstructed at runtime from durable repository evidence rather than being persisted as durable state.

## Repository Evidence

The Conversation Context Runtime reconstructs the behavioral decision pipeline:

Conversation History
→ Interpretation Context
→ Authority Evaluation
→ Contamination Evaluation
→ History Selection
→ Conversation Context

The production workflow consumes the resulting `selectedHistory` before invoking `ollamaChat()`.

Repository inspection found no persistence of:

- authorityEvaluation
- contaminationEvaluation
- evaluatedInterpretations
- contaminationEvaluations
- selectedHistory

These values exist only as runtime-derived read models.

Durable repository artifacts remain:

- Conversation Turns
- Interpretation Evidence Ledger (IEL)
- Interpretation Lifecycle state
- Living Draft artifacts
- Reconciled Intent artifacts
- Approval / Package / Delegation / Envelope artifacts

## Architectural Finding

The repository persists evidence.

Behavioral decisions are reconstructed from that evidence during Conversation Context composition.

The workflow consumes reconstructed behavioral decisions rather than recreating them.

## Implications

This architecture provides:

- a single authoritative source of truth
- deterministic behavioral reconstruction
- avoidance of persisted derived state
- ability to improve behavioral evaluation without requiring data migration

## Notes

This document records a repository-verified architectural finding.

It is not, at this time, promoted to an Immutable Architectural Invariant. Promotion should occur only after the finding continues to hold across subsequent Behavioral Integration corridors.
