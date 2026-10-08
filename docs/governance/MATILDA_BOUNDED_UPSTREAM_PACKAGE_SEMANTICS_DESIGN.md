# Matilda — Bounded Upstream Package Semantics Design

## Status
DESIGN AUTHORIZED — IMPLEMENTATION NOT AUTHORIZED

## Problem
Matilda may receive a concrete request such as:
"Remove the Packages tab from the sidebar while preserving underlying package functionality and authority."

When Ollama omits `expectedOutcome`, upstream validation rejects the response before downstream workflow reconciliation can occur.

The previous downstream projection was rolled back.

## Design Decision
A narrowly bounded reconciliation may be introduced after structured response parsing and before upstream Package Semantics fidelity validation.

Reconciliation must not silently overwrite contradictory model-authored semantics.

## Eligibility
Reconciliation is permitted only when:
- The current request establishes a concrete operation and subject.
- The requested outcome is deterministically recoverable.
- The model-authored expected outcome is missing or null.
- No model-authored field contradicts the recovered outcome.
- Explicit structured user semantics remain unchanged.
- No unsupported implementation details or authority are inferred.

## Required Behavior
1. Preserve the explicit user operation and subject.
2. Preserve material constraints.
3. Preserve existing valid model-authored fields.
4. Apply all existing Package Semantics validators.
5. Notify observers only after successful validation.
6. Persist only the validated result.

## Fail-Closed Boundaries
Reject rather than reconcile when:
- The model-authored outcome contradicts the user request.
- Another model-authored field contradicts the recovered outcome.
- Explicit structured user semantics conflict.
- The operation or subject is ambiguous.
- The response is malformed.
- The request is insufficiently concrete.
- Existing fidelity validation fails.

## Governance Invariants
- Package Semantics remain non-authoritative.
- Approval, delegation, validation, and execution remain separate.
- No new authority is introduced.
- No generic shell execution is introduced.
- Failed validation must not create successful durable evidence.
- Existing Package functionality and governance must remain intact.

## Required Tests
- Missing expected outcome with concrete request.
- Preservation of explicit constraints.
- Valid model-authored outcome remains unchanged.
- Contradictory outcome fails closed.
- Contradictory non-outcome field fails closed.
- Explicit user semantics preserve exact fidelity.
- Vague requests do not trigger projection.
- Malformed responses remain rejected.
- Observer receives only validated semantics.
- Workflow persistence matches validated semantics.
- Failed workflow creates no successful interpretation evidence.
- No authority changes occur.

Tests must exercise the actual upstream runtime seam.

## Current Determination
DESIGN=AUTHORIZED
IMPLEMENTATION=NOT_AUTHORIZED
DOGFOOD=NOT_AUTHORIZED
PREVIOUS_PROJECTION=ROLLED_BACK
NEXT_GATE=EXPLICIT_IMPLEMENTATION_AUTHORIZATION
