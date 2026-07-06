
/*

Preview Confirmation Runtime

Produces:

- confirmation_id

- preview_id

- execution_plan_id

- package_id

- lineage_id

- confirmation_actor

- confirmation_timestamp

- confirmation_result

- status

- created_at

Required invariants:

Preview Confirmation MUST:

- require explicit operator confirmation

- remain deterministic

- preserve auditability

Preview Confirmation MUST NOT:

- authorize execution

- execute shell commands

- mutate the filesystem

- modify databases beyond persisting the confirmation artifact

Authority Boundary:

Only explicit operator confirmation may create a Preview Confirmation.

Preview Confirmation establishes execution-authorization eligibility only.

Execution authority remains in the next corridor.

*/

