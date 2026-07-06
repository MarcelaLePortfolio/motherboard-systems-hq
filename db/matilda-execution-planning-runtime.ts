
/*

Dry-Run Execution Planning Runtime

Produces:

- execution_plan_id

- assignment_id

- package_id

- lineage_id

- planned_steps

- planned_mutations

- rollback_references

- ambiguity_findings

- reconciliation_summary

- status

- created_at

Required invariants:

Execution Planning MUST:

- remain deterministic

- remain dry-run only

- remain non-mutating

- preserve rollback visibility

- preserve reconciliation visibility

Execution Planning MUST NOT:

- execute shell commands

- mutate the filesystem

- modify databases beyond persisting the dry-run plan

- authorize execution

- bypass Preview

- bypass Explicit Preview Confirmation

*/

