
# Matilda Living Draft Package Scope

Date: 2026-07-05

## Corridor

Interpretation Evidence Ledger → Living Draft Package

## Current Stable Checkpoint

HEAD: 7d8a6bd9

Latest DR: 20260705_223618

## Objective

Implement the next Matilda Conversation Engine layer: a non-authoritative Living Draft Package synthesized from Interpretation Evidence Ledger entries.

## Current Runtime Position

Conversation

→ Interpretation Evidence Ledger

→ No Package

→ No Delegation

→ No Envelope

→ No Cade execution

## Target Runtime Position

Conversation

→ Interpretation Evidence Ledger

→ Living Draft Package

→ Reconciled Interpretation Summary

→ User Approval

→ Canonical Package

→ Delegation

→ Governance Validation

→ Envelope

→ Cade execution

## Definition

A Living Draft Package is Matilda's current best synthesis of an active interpretation lineage.

It is:

- derived from IEL entries

- updateable

- non-authoritative

- not user-approved

- not governance-consumable

- upstream of Canonical Package creation

## In Scope

- Define a Living Draft Package runtime shape.

- Add persistence for a draft package record.

- Link the draft package to IEL-derived evidence.

- Preserve current best understanding.

- Preserve unresolved questions.

- Preserve scope assumptions.

- Preserve constraints.

- Preserve expected outcomes.

- Preserve non-authoritative status.

## Out of Scope

- User approval.

- Canonical Package creation.

- Delegation.

- Ellis validation.

- Atlas readiness scoring.

- Envelope creation.

- Cade execution.

## Success Criteria

A runtime call can create or update a Living Draft Package from existing IEL evidence.

The Living Draft Package contains:

- draft_package_id

- lineage_id

- current_interpretation

- proposed_work

- proposed_artifacts

- in_scope

- out_of_scope

- constraints

- expected_outcome

- unresolved_questions

- evidence_entry_ids

- status

Creating or updating a Living Draft Package must not create a Canonical Package.

Creating or updating a Living Draft Package must not authorize Delegation, Validation, Envelope creation, routing, assignment, or Cade execution.

## Authority Boundary

Matilda may synthesize a Living Draft Package.

Matilda may not treat a Living Draft Package as approved meaning.

Matilda may not delegate from a Living Draft Package.

Matilda may not create a Canonical Package without explicit user approval.

## Next Milestone

Implement Living Draft Package persistence and validate it with existing IEL entries.

