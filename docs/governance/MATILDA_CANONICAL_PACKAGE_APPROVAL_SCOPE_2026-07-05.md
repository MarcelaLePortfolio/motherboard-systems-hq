
# Matilda Canonical Package Approval Runtime Scope

Date: 2026-07-05

## Corridor

Reconciled Interpretation Summary

→ Explicit Operator Approval

→ Canonical Package

## Objective

Implement the approval corridor that allows an operator to explicitly approve a Reconciled Interpretation Summary and create the first Canonical Package.

Approval is the first authority-changing event in the Conversation Engine.

Nothing before approval is authoritative.

## In Scope

- Explicit approval endpoint.

- Canonical Package persistence.

- Immutable snapshot of the approved Reconciled Interpretation Summary.

- Approval timestamp.

- Approval actor.

- Package identifier.

- Package lineage.

## Out of Scope

- Delegation.

- Ellis Validation.

- Envelope creation.

- Routing.

- Assignment.

- Cade execution.

- Atlas readiness scoring.

## Success Criteria

A runtime call can create a Canonical Package containing:

- package_id

- summary_id

- draft_package_id

- lineage_id

- approved_interpretation

- approved_work

- approved_artifacts

- approved_scope

- approved_constraints

- approved_expected_outcome

- approval_actor

- approval_timestamp

- status

Creating a Canonical Package must not authorize:

- Delegation

- Governance Validation

- Envelope creation

- Routing

- Assignment

- Cade execution

## Authority Boundary

Only explicit operator approval may create a Canonical Package.

Matilda may present approval candidates.

Matilda may not self-approve.

Creation of a Canonical Package does not itself authorize downstream execution.

## Next Milestone

Implement Canonical Package persistence and validate explicit approval from an existing Reconciled Interpretation Summary.

