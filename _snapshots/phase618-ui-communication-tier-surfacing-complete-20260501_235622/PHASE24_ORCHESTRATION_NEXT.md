Phase 24 — Orchestration Polish / Consolidation

Baseline:
- Phase 23 complete
- task_events SSE → Matilda chat bridge verified
- task.event emits cleanly
- UI renders HQ-style lifecycle lines with meta tails

Phase 24 Goals:
1. Orchestration determinism
   - Normalize task lifecycle states (created → running → completed / failed)
   - Enforce single-writer semantics for task_events
   - Optional correlation_id / parent_task_id support

2. SSE consolidation
   - Shared envelope shape across ops + task-events
   - Reconnect safety (no duplicate lifecycle lines)
   - Optional replay-window guard (last N events)

3. Matilda handoff polish
   - Explicit orchestration summary on task completion
   - Suppress low-signal intermediate events in chat
   - Preserve full fidelity in HQ dashboard

4. Phase discipline
   - Lock Phase 23 as golden before behavioral changes

