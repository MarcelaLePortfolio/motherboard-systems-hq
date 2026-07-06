
/*

Routing Runtime

Produces:

- routing_id

- envelope_id

- package_id

- lineage_id

- routing_destination

- routing_rationale

- routing_timestamp

- status

- created_at

Required invariants:

Creating a Routing record MUST NOT:

- authorize assignment

- authorize Cade execution

Authority Boundary:

Only explicit routing may create a Routing record.

Routing establishes assignment eligibility only.

Execution authority remains in later corridors.

*/

