# PHASE 87.2 — SITUATION SUMMARY INPUT MAPPING

Status: IN PROGRESS  
Date: 2026-03-18

────────────────────────────────

## OBJECTIVE

Define how existing system signals map into SituationSummary inputs.

This phase defines mapping only.

No signal creation.  
No recomputation.  
No reducers.  
No execution coupling.

────────────────────────────────

## PURPOSE

Phase 87.1 created the composer.

Phase 87.2 defines:

Where inputs come from.
How they normalize.
How ambiguity is handled.

Goal:

Deterministic mapping from repo truth → SituationSummaryInputs.

────────────────────────────────

## MAPPING RULES

Mapping must:

Use existing summaries only  
Prefer highest-level signals  
Avoid duplicate interpretation  
Avoid recomputation  

Priority:

Existing cognition summaries > signal summaries > raw telemetry.

────────────────────────────────

## INPUT TARGETS

SituationSummaryInputs fields require mapping definitions:

stabilityState  
executionRiskState  
cognitionState  
signalCoherenceState  
operatorAttentionState  

This phase defines interpretation contracts only.

────────────────────────────────

## STABILITY STATE SOURCE

Candidate sources:

System health summaries  
Run lifecycle integrity checks  
Replay validation state  
Reducer safety state  

Mapping rule:

If all stability signals positive → stable

If any degradation signal present → degraded

If unavailable → unknown

No scoring.

Binary interpretation only.

────────────────────────────────

## EXECUTION RISK SOURCE

Candidate sources:

Policy signals  
Task execution anomalies  
Lease violations  
Reducer anomalies  

Mapping rule:

If no known anomalies → none

If anomaly signals present → elevated

If unavailable → unknown

No predictive logic.

No forward inference.

────────────────────────────────

## COGNITION STATE SOURCE

Candidate sources:

Cognition summaries
Signal summary coherence
Composition validity checks

Mapping rule:

If cognition layers aligned → consistent

If mixed signals present → mixed

If unavailable → unknown

────────────────────────────────

## SIGNAL COHERENCE SOURCE

Candidate sources:

Signal composition layer
Summary agreement signals
Conflict detection signals

Mapping rule:

If summaries agree → coherent

If summaries conflict → divergent

If unavailable → unknown

────────────────────────────────

## OPERATOR ATTENTION SOURCE

Candidate sources:

Operator signals
Operator diagnostics layer
Operator workflow helpers

Mapping rule:

If no attention flags → none

If advisory flags → recommended

If blocking flags → required

If unavailable → unknown

────────────────────────────────

## PHASE DISCIPLINE

Phase remains:

Deterministic  
Mapping only  
No execution coupling  
No UI wiring  

Not allowed:

Confidence scoring  
Risk scoring  
Early warnings  
Automation triggers  

Future phases.

────────────────────────────────

END PHASE 87.2 INPUT MAPPING
