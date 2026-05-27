Phase 24 — Step 1: Task Lifecycle Normalization

Objective:
Establish a deterministic, canonical task lifecycle enforced at emit-time.

Canonical States:
- created
- running
- completed
- failed

Rules:
- Exactly one terminal state per task (completed | failed)
- Terminal state is final and immutable
- running may be emitted multiple times but must not regress
- created emitted once at task instantiation

Event Contract (task.event):
{
  task_id: string
  state: "created" | "running" | "completed" | "failed"
  ts: number
  actor: string
  meta?: object
}

Enforcement Plan:
1. Centralize lifecycle validation in task_events emitter
2. Reject invalid state transitions (log + drop)
3. Add optional parent_task_id + correlation_id (no UI use yet)
4. No UI changes in Step 1

Exit Criteria:
- Invalid transitions cannot be emitted
- Existing Phase 23 flows remain unchanged
- SSE stream remains syntax-safe
