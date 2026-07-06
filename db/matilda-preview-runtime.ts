
/*

Preview Runtime

Produces:

- preview_id

- execution_plan_id

- assignment_id

- package_id

- lineage_id

- preview_summary

- preview_steps

- preview_mutations

- rollback_references

- reconciliation_summary

- status

- created_at

Required invariants:

Preview Generation MUST:

- remain deterministic

- remain read-only

- remain non-mutating

- preserve rollback visibility

- preserve reconciliation visibility

Preview Generation MUST NOT:

- confirm the preview

- authorize execution

- execute shell commands

- mutate the filesystem

- modify databases beyond persisting the preview artifact

Authority Boundary:

Preview is a user-visible review artifact only.

Execution authority remains in a later corridor.

*/

