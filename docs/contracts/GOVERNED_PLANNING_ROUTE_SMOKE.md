
# Governed Planning Route Smoke

## Purpose

Validate that the governed planning API route preserves:

- dry-run-only behavior

- fail-closed governance validation

- approval-gated planning semantics

- non-mutating execution discipline

without enabling:

- mutation execution

- shell execution

- autonomous execution

- PM2 runtime mutation

- filesystem mutation

- legacy run_shell promotion

## Expected Smoke Result

The route must produce:

- canonical envelope drafting

- governance validation

- approval gate evaluation

- Cade dry-run planning output

- reconciliation-ready planning artifacts

while preserving:

- mutation_authorized = false

- shell_execution_authorized = false

- autonomous_execution_authorized = false

## Locked Boundary

The governed planning route is:

- planning only

- deterministic

- reconciliation oriented

- fail closed

It is NOT:

- an execution endpoint

- a mutation endpoint

- a shell routing endpoint

- an orchestration runtime

- an autonomous runtime surface

