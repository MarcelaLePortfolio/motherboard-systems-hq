
/*

Envelope Runtime

Produces:

- envelope_id

- validation_id

- delegation_id

- package_id

- lineage_id

- required_capabilities

- operational_corridor

- lifecycle_state

- status

- created_at

Required invariants:

Creating an Envelope MUST NOT:

- authorize routing

- authorize assignment

- authorize Cade execution

Authority Boundary:

Only explicit Envelope creation may create an Envelope.

Envelope creation establishes routing eligibility only.

Execution authority remains in later corridors.

*/

