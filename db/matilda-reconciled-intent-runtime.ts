
/*

Matilda Reconciled Intent Summary Runtime

Corridor:

Living Draft Package

→ Reconciled Intent Summary

Responsibilities:

1. Read the current Living Draft Package.

2. Produce a human-reviewable Reconciled Intent Summary.

3. Preserve unresolved questions.

4. Recommend the next action.

5. Preserve governance boundaries.

Summary shape:

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

- created_at

Required invariants:

Generating a Reconciled Intent Summary MUST NOT:

- create a Canonical Package

- authorize Delegation

- authorize Governance Validation

- authorize Envelope creation

- authorize routing

- authorize assignment

- authorize Cade execution

Authority Boundary:

Matilda may generate a Reconciled Intent Summary.

The summary remains a review artifact only.

Only explicit operator approval may create a Canonical Package.

*/

