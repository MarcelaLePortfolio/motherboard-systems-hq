
/*

Governance Validation Runtime

Produces:

- validation_id

- delegation_id

- package_id

- lineage_id

- validation_actor

- validation_timestamp

- findings

- validation_result

- status

- created_at

Required invariants:

Completing Governance Validation MUST NOT:

- create an Envelope

- authorize routing

- authorize assignment

- authorize Cade execution

Authority Boundary:

Only explicit operator validation may complete Governance Validation.

Governance Validation establishes governance completeness only.

Execution authority remains in later corridors.

*/

