
# Governance Artifact Consumption — Operational Intake Decision

Status: STABILIZED ARCHITECTURAL DECISION

## Decision

Operational Intake is a separate, deterministic, authority-neutral layer between Lifecycle and Ellis Coordination.

Canonical flow:

Package

↓

Delegation

↓

Governance Validation

↓

Envelope Gate

↓

Envelope

↓

Lifecycle

↓

ASSIGNED

↓

Operational Intake

↓

Ellis Coordination

## Operational Intake Responsibilities

Operational Intake SHALL:

- Pull eligible ASSIGNED Envelopes.

- Verify intake eligibility.

- Ensure idempotent intake.

- Record operational intake evidence.

- Expose read-only intake records to Ellis.

Operational Intake SHALL NOT:

- Interpret intent.

- Define capabilities.

- Modify governance artifacts.

- Modify lifecycle state.

- Assign actors.

- Route work.

- Schedule work.

- Claim work.

- Execute work.

- Make coordination decisions.

## Architectural Invariant

Operational Intake is the authority-neutral bridge between lifecycle-authorized governance artifacts and Ellis Coordination.

It records read-only operational consumption evidence without becoming governance, lifecycle, assignment, routing, scheduling, orchestration, worker, or execution authority.

## Scope Boundary

Implementation remains unauthorized.

This document records the architectural decision only.

## Next Canonical Corridor

Define the Operational Intake architectural contract while preserving established authority boundaries.

