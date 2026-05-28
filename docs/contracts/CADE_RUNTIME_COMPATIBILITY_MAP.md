
# Cade Runtime Compatibility Map

## Context

This map follows the Cade runtime archaeology and active reference audit.

It classifies discovered Cade runtime paths against the current canonical execution-governance corridor.

## Current Verified Facts

Cade is not merely conceptual.

Cade has historical and active runtime references.

The active references include PM2/start-script paths for:

- `scripts/_local/agent-runtime/launch-cade.ts`

- `scripts/_local/agent-runtime/cade-processor.ts`

- `scripts/_local/agent-runtime/utils/cade_task_processor.ts`

The active references also include shell-capable task handling through `run_shell`.

## Active Runtime References

### PM2 / Start Scripts

The audit found active start references in:

- `toggle_agents.sh`

- `start_all.sh`

- `scripts/system/toggle_agents.sh`

- restore tooling

These references launch Cade through:

- `launch-cade.ts`

- `cade-processor.ts`

### Cade Processor Path

The active processor path imports:

- `startCadeTaskProcessor`

from:

- `scripts/_local/agent-runtime/utils/cade_task_processor.js`

The TypeScript source mirrors:

- `scripts/_local/agent-runtime/utils/cade_task_processor.ts`

### Task Router Path

The launch path references:

- `routeTask`

from:

- `scripts/_local/handlers/taskRouter.ts`

### Mirror Runtime Path

The launch path references:

- `createAgentRuntime`

from:

- `mirror/agent`

This appears to provide agent heartbeat/runtime surface behavior.

## Compatibility Classification

### Compatible As Historical Evidence

These files prove Cade runtime intent and prior wiring:

- `launch-cade.ts`

- `cade-processor.ts`

- `cade_task_processor.ts`

- `taskRouter.ts`

- `mirror/agent.ts`

- `toggle_agents.sh`

- `start_all.sh`

### Not Directly Compatible With Current Governance Corridor

The shell-capable processors are not directly compatible with the new governed execution-envelope corridor because they do not currently enforce:

- execution envelope validation

- delegation authorization state

- mutation scope

- forbidden path guard

- rollback contract

- reconciliation contract

- sandbox dry-run requirement

- Motherboard Systems critical-infrastructure restrictions

### High-Risk Existing Capability

The existing `run_shell` pathway is execution-capable.

It must remain treated as legacy/high-risk until wrapped by a governed adapter or disabled for production paths.

## Architecture Decision

Do not wire the existing `run_shell` processor directly to the canonical delegation route.

Do not remove the historical runtime yet.

Do not assume Cade must be rebuilt from scratch.

Instead, introduce a governed compatibility layer that can inspect or adapt existing Cade runtime capabilities without enabling unsafe execution.

## Recommended Next Implementation Slice

Create a read-only Cade execution compatibility adapter that:

- imports or describes the canonical envelope

- accepts a validated envelope

- refuses non-dry-run execution

- emits a planned execution summary

- does not call `child_process.exec`

- does not mutate files

- produces reconciliation-ready output

This provides a safe bridge between:

- existing Cade runtime history

- new canonical execution governance

## Boundary

This map is documentation only.

No runtime behavior was changed.

No autonomous execution was enabled.

No shell execution path was expanded.

