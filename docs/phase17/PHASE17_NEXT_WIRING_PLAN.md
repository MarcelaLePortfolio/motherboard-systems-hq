Phase 17 checkpoint:
- Tag: v17.0-orchestration-pure-scaffolds
- Branch: feature/phase17-orchestration

What’s done (pure + tested):
1) Task state machine: server/orchestration/task-state-machine.ts
2) Event → policy → task loop (types + pipeline runner): server/orchestration/policy.ts, policy-pipeline.ts
3) Routing + dependencies: server/orchestration/router.ts, deps.ts
4) Scheduling/throttling: server/orchestration/scheduler.ts
5) Operator mode/intent commands: server/orchestration/operator-commands.ts

What’s next (Phase 18: wiring, still safe/additive):
A) Add an in-memory OrchestratorStore (tasks + ctx + agent snapshots), behind flag:
   - env: PHASE18_ENABLE_ORCHESTRATION=1
B) Add an ingestion endpoint or internal hook for:
   - operator commands (string) -> parse -> decisions -> emitted events -> pipeline
   - task lifecycle events (task.transition)
C) Produce a minimal "orchestration.tick" loop:
   - read queued tasks
   - deps check -> router -> scheduler eligibility -> emit transitions
D) Publish observability:
   - log lines + optional SSE stream "orchestration.state" (gated)
E) Keep Phase 16 UI untouched; any UI integration is opt-in later.

Hard rules:
- No agent execution yet. Phase 18 only proves deterministic state evolution + routing decisions.
- No database requirement. Keep in-memory first; persistence later once loop is stable.
