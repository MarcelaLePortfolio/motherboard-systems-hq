
/*

Matilda Canonical Package Runtime

Corridor:

Reconciled Intent Summary

→ Explicit Operator Approval

→ Canonical Package

Responsibilities:

1. Persist immutable Canonical Packages.

2. Accept only approved Reconciled Intent Summaries.

3. Preserve immutable lineage.

4. Record approval metadata.

5. Remain downstream of approval and upstream of Delegation.

Canonical Package fields:

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

- created_at

Required invariants:

Creating a Canonical Package MUST NOT:

- authorize Delegation

- authorize Governance Validation

- authorize Envelope creation

- authorize routing

- authorize assignment

- authorize Cade execution

Authority Boundary:

Only explicit operator approval may create a Canonical Package.

Canonical Package creation establishes approved intent only.

Execution authority begins in later governance corridors.

*/

