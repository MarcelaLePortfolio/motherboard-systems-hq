
# PHASE 719 — EXECUTION CONTRACT FLOW INSPECTION

## PURPOSE

Read-only inspection of the active execution contract flow.

Goal:

Trace exactly how:

- output

- notes

- strategy_applied

- meta

from:

`server/worker/task_execution_interpreter.mjs`

become:

- outcome_preview

- explanation_preview

- markdown artifact sections

- artifact preview content

## SAFETY

No mutations permitted.

Do not alter:

- DB schema

- retry/requeue contracts

- SSE behavior

- renderer logic

- advisory boundaries

## TARGET

Primary file:

`server/worker/execute_task_with_contract.mjs`

Secondary references:

- artifact writers

- markdown generators

- completion payload builders

- task completion persistence

