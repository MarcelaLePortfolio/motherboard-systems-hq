
# Cade Runtime Archaeology Findings

## Context

This discovery was performed after the execution-governance corridor was stabilized and backed up.

The purpose was to determine whether Cade already had historical agent/runtime wiring before building any new execution substrate.

## Finding

Cade does have historical agent/runtime/tooling artifacts in the repository.

This confirms that Cade was not merely conceptual.

## High-Signal Files Inspected

- cade_task_processor.ts

- cade_task_processor_clean.ts

- cade-processor.ts

- launch-cade.ts

- cade-delegation-watcher.ts

- agent-to-cade.ts

- cade.ts

## Observed Capabilities

### cade_task_processor.ts

- Reads from `./memory/agent_chain_state.json`

- Polls every 3 seconds

- Looks for tasks assigned to Cade

- Executes tasks of type `run_shell`

- Uses `child_process.exec`

- Marks tasks Completed or Failed

### cade_task_processor_clean.ts

- Similar to `cade_task_processor.ts`

- Executes pending `run_shell` tasks

- Uses `child_process.exec`

- Writes task status back to `memory/agent_chain_state.json`

### cade-processor.ts

- Starts `startCadeTaskProcessor`

- Keeps process alive

### launch-cade.ts

- References agent runtime creation

- References Cade agent definition

- Reads chain state

- Routes assigned task through `routeTask`

- Writes Completed or Failed state

- Appears syntactically stale or incomplete in current form

### cade-delegation-watcher.ts

- Polls pending delegation events

- Writes `public/delegation_success.html`

- Marks task events completed

- Pushes reflection

- Uses SQLite task events

### agent-to-cade.ts

- Contains a stubbed `delegateToCadeV2`

- No implementation yet

### cade.ts

- Exposes Cade recent-event route

- Reads recent Cade task events from DB

## Architectural Interpretation

Cade has historical execution-oriented wiring.

However, inspected runtime paths appear to predate the current governed execution-envelope corridor.

These paths are not currently verified as compatible with:

- canonical execution envelopes

- mutation-scope enforcement

- rollback contracts

- reconciliation contracts

- dry-run requirements

- Motherboard Systems critical-infrastructure safeguards

## Risk Finding

The older Cade processor paths include direct shell execution through `child_process.exec`.

This is execution-capable but not governance-bound.

It should not be promoted into the current execution corridor without wrapping, restricting, or replacing it.

## Current Conclusion

Do not build Cade execution from scratch until existing runtime paths are fully mapped.

Do not wire existing Cade shell execution directly into the new delegation route.

The next safe step is compatibility mapping:

- which Cade files are active

- which are legacy

- which are broken/stale

- which can be adapted into a dry-run governed adapter

- which should be archived or explicitly avoided

## Boundary

This document records findings only.

No runtime behavior was changed.

No autonomous execution was enabled.

No shell execution path was expanded.

