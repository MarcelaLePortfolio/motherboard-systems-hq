
/*

Next implementation target:

Matilda Living Draft Package Runtime

Responsibilities:

- Define the Living Draft Package persistence layer.

- Create or update a draft package from IEL evidence.

- Maintain append-only IEL references.

- Preserve non-authoritative status.

Required fields:

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

- created_at

- updated_at

Required invariants:

Creating or updating a Living Draft Package MUST NOT:

- create a Canonical Package

- authorize Delegation

- authorize Governance Validation

- authorize Envelope creation

- authorize routing

- authorize assignment

- authorize Cade execution

Authority Boundary:

Matilda may synthesize a Living Draft Package.

A Living Draft Package remains a working interpretation only.

Explicit user approval is still required before Canonical Package creation.

*/

