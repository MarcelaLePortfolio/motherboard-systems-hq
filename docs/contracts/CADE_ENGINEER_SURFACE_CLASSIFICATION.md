
# Cade Engineer Surface Classification

## Context

This classification follows the captured Cade engineer surface contents.

Cade has always been intended as the system engineer.

The current task is not to decide whether Cade is the engineer.

The current task is to reconcile Cade's historical engineering runtime with the newly stabilized execution-governance corridor.

## Confirmed Engineer Surface

The following live or active-referenced files confirm Cade's engineer/runtime surface:

- `scripts/_local/agent-runtime/launch-cade.ts`

- `scripts/_local/agent-runtime/cade-processor.ts`

- `scripts/_local/agent-runtime/utils/cade_task_processor.ts`

- `scripts/_local/handlers/taskRouter.ts`

- `scripts/_local/agent-runtime/handlers/handleTask.ts`

- `scripts/_local/agent-runtime/submit-task.ts`

- `mirror/agent.ts`

- `scripts/system/toggle_agents.sh`

- `start_all.sh`

## Confirmed Runtime Identity

Cade currently has evidence of all of the following historical roles:

- PM2-managed runtime agent

- heartbeat/runtime surface

- task-state reader

- task router

- task processor

- shell-capable executor

- filesystem-capable task handler

- delegated engineering worker

## Current Active Launch Path

The active PM2/start paths reference:

- `launch-cade.ts`

- `cade-processor.ts`

`launch-cade.ts`:

- reads chain state

- checks for tasks assigned to Cade

- routes assigned tasks through `routeTask`

- writes Completed or Failed state

- starts `createAgentRuntime(cade)`

`cade-processor.ts`:

- starts `startCadeTaskProcessor`

- keeps the process alive

## Current Execution Capability

`cade_task_processor.ts`:

- reads `./memory/agent_chain_state.json`

- polls every 3 seconds

- finds pending Cade tasks

- executes tasks of type `run_shell`

- uses `child_process.exec`

- marks tasks Completed or Failed

`handleTask.ts`:

- can generate files

- can execute shell commands with `execSync`

- appends task records to local memory

`submit-task.ts`:

- can submit `run_shell` tasks

- can submit `generate_file` tasks

- writes to `memory/agent_chain_state.json`

## Governance Compatibility Finding

The existing Cade engineer runtime is real but predates the current canonical execution-governance corridor.

The existing runtime does not currently enforce:

- canonical execution envelope validation

- delegation authorization state

- mutation-scope guard

- forbidden path guard

- rollback contract

- validation contract

- reconciliation contract

- sandbox dry-run requirement

- Motherboard Systems critical-infrastructure restrictions

## Architectural Decision

Cade remains the system engineer.

The legacy runtime must not be directly promoted as the governed execution engine.

The correct path is to introduce a governed Cade engineer adapter that preserves Cade's role while changing the execution contract.

## New Contract Direction

Cade should evolve from:

raw task / command executor

to:

governed envelope-native engineering adapter

## Required Adapter Properties

The first governed Cade engineer adapter must:

- accept a validated execution envelope

- refuse non-delegated envelopes

- refuse non-dry-run execution initially

- enforce mutation scope

- refuse forbidden paths

- produce a planned engineering summary

- produce reconciliation-ready output

- avoid `child_process.exec`

- avoid direct filesystem mutation

- avoid autonomous loops

## Non-Negotiable Boundary

Do not wire existing `run_shell` behavior into the canonical delegation route.

Do not delete the existing Cade runtime during this phase.

Do not build a second conflicting Cade architecture.

Do wrap Cade's existing engineer identity in the canonical governance corridor.

## Current Conclusion

Cade is confirmed as the intended system engineer.

The next implementation slice should create a read-only, dry-run, envelope-native Cade engineer adapter.

That adapter becomes the bridge between:

- Matilda's governed execution envelopes

- Cade's historical engineering role

- future authorized mutation behavior

