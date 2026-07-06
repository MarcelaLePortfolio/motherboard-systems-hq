
/*

Matilda Living Draft Synthesis Runtime

Purpose:

Transform one or more Interpretation Evidence Ledger (IEL) entries into a

single updated Living Draft Package.

This runtime is intentionally non-authoritative.

Inputs:

- lineage_id

- evidence_entry_ids

Responsibilities:

1. Read IEL entries.

2. Produce a synthesized working interpretation.

3. Update only the Living Draft Package.

4. Preserve complete evidence lineage.

5. Remain deterministic and repeatable.

Output fields:

- current_interpretation

- proposed_work

- proposed_artifacts

- in_scope

- out_of_scope

- constraints

- expected_outcome

- unresolved_questions

- evidence_entry_ids

- updated_at

Required invariants:

Running synthesis MUST NOT:

- create a Canonical Package

- authorize Delegation

- authorize Governance Validation

- authorize Envelope creation

- authorize routing

- authorize assignment

- authorize Cade execution

Authority Boundary:

Matilda may improve a Living Draft Package.

The synthesized draft remains a working interpretation.

Only explicit operator approval may create a Canonical Package.

*/

