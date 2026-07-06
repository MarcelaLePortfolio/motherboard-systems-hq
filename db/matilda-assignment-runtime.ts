
/*

Assignment Runtime

Produces:

- assignment_id

- routing_id

- package_id

- lineage_id

- assigned_agent

- assignment_rationale

- assignment_timestamp

- status

- created_at

Required invariants:

Creating an Assignment MUST NOT:

- authorize Cade execution

Authority Boundary:

Only explicit assignment may create an Assignment.

Assignment establishes execution eligibility only.

Execution authority remains in the next corridor.

*/

