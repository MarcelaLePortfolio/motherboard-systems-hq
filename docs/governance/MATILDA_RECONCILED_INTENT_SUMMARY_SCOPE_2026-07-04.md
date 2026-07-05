
# Matilda Reconciled Intent Summary Scope

Date: 2026-07-04

## Corridor

Matilda Intent Discussion → Reconciled Intent Summary

## Objective

Implement the first pipeline step where Matilda turns an intent discussion into a reviewable Reconciled Intent Summary before any Package is created.

## Finding

Existing doctrine defines the lifecycle:

Collaboration

→ Reconciled Intent Summary

→ Approval

→ Package Creation

→ Pending Delegation

→ Delegation

→ Governance Validation

Existing package doctrine defines required Package contents, including:

- Intent Summary

- Proposed Work

- Proposed Artifacts

- Scope Boundary

- Constraints

- Expected Outcome

- Delegation Target

No implemented Reconciled Intent Summary schema or runtime currently exists.

## In Scope

- Define a Reconciled Intent Summary shape.

- Add a Matilda-facing route or helper that produces a Reconciled Intent Summary from a discussion input.

- Keep the summary human-reviewable.

- Preserve the rule that no Package exists during collaboration.

- Preserve explicit approval before Package creation.

## Out of Scope

- Automatic Package creation from keywords.

- Ellis validation.

- Envelope creation.

- Cade execution.

- Delegation.

- Routing.

- Assignment.

- Autonomous implementation.

## Success Criteria

A request to Matilda can produce a structured Reconciled Intent Summary containing:

- interpreted objective

- proposed work

- proposed artifacts

- in-scope work

- out-of-scope work

- constraints

- expected outcome

- unresolved questions

- recommended next action

The response must not create a Package.

## Authority Boundary

Matilda may interpret and summarize intent.

Matilda may not treat a summary as approval.

Matilda may not create a Package without explicit approval.

## Next Milestone

Implement Reconciled Intent Summary generation in the Matilda chat stub as a collaboration artifact only.

