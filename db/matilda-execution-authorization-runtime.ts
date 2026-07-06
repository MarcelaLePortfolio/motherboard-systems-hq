
/*

Execution Authorization Runtime

Produces:

- authorization_id

- confirmation_id

- preview_id

- execution_plan_id

- package_id

- lineage_id

- authorization_actor

- authorization_timestamp

- authorization_result

- status

- created_at

Required invariants:

Execution Authorization MUST:

- require explicit operator authorization

- remain deterministic

- preserve auditability

Execution Authorization MUST NOT:

- execute Cade

- execute shell commands

- mutate the filesystem

- modify databases beyond persisting the authorization artifact

Authority Boundary:

Only explicit operator authorization may create an Execution Authorization.

Execution Authorization establishes Cade execution eligibility only.

Actual Cade execution remains a separate corridor.

*/

