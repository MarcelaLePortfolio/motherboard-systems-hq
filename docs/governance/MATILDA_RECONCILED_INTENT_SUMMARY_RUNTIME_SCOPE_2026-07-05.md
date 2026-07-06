
# Matilda Reconciled Intent Summary Runtime Scope

Date: 2026-07-05

## Corridor

Living Draft Package → Reconciled Intent Summary

## Current Stable Checkpoint

HEAD: b42ab35d

Latest DR: 20260705_230131

## Objective

Implement the next Matilda Conversation Engine layer: generating a human-reviewable Reconciled Intent Summary from the current non-authoritative Living Draft Package.

## Current Validated Flow

Chat

→ Interpretation Evidence Ledger

→ Living Draft Package synthesis

→ No approval bypass

→ No execution

## Target Flow

Chat

→ Interpretation Evidence Ledger

→ Living Draft Package synthesis

→ Reconciled Intent Summary

→ User Approval

→ Canonical Package

→ Delegation

→ Governance Validation

→ Envelope

→ Cade execution

## In Scope

- Define Reconciled Intent Summary runtime shape.

- Generate summary from a Living Draft Package.

- Preserve human-reviewable format.

- Preserve unresolved questions.

- Preserve approval boundary.

- Preserve non-authoritative pre-approval status.

## Out of Scope

- Canonical Package creation.

- Approval event handling.

- Delegation.

- Ellis validation.

- Atlas readiness scoring.

- Envelope creation.

- Cade execution.

## Success Criteria

A runtime call can generate a Reconciled Intent Summary containing:

- summary_id

- draft_package_id

- lineage_id

- interpreted_objective

- proposed_work

- proposed_artifacts

- in_scope

- out_of_scope

- constraints

- expected_outcome

- unresolved_questions

- recommended_next_action

- approval_required

- status

Generating a Reconciled Intent Summary must not create a Canonical Package.

Generating a Reconciled Intent Summary must not authorize Delegation, Validation, Envelope creation, routing, assignment, or Cade execution.

## Authority Boundary

Matilda may generate a Reconciled Intent Summary.

Matilda may not treat the summary as approval.

Matilda may not create a Canonical Package without explicit user approval.

