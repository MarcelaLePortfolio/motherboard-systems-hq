# Phase 57B — Operator Panel Polish

Goal: Make the orchestration lifecycle visually understandable to an operator on a fresh boot.

Backend proof is already complete (Phase 46–57).
This phase improves dashboard clarity only.

Guardrails:
- Do NOT expand architecture
- Do NOT modify backend APIs
- Do NOT modify policy system
- Do NOT modify workers or schema
- Only improve dashboard presentation

--------------------------------------------------

Milestone 1 — Clean Cold Start

Success Conditions

- Dashboard loads without console errors
- /api/health visible immediately
- Clear loading state before data arrives
- Clean empty state when no runs exist

Operator Signal

System Status: Healthy

--------------------------------------------------

Milestone 2 — Deterministic Run Ordering

Runs sorted by most recent activity.

Success Conditions

- Runs sorted by last_event_ts
- Most recent run appears first
- No flickering order changes
- Snapshot rows consistent

Expected display

policy.probe.run
running → completed

--------------------------------------------------

Milestone 3 — Run Lifecycle Visibility

Lifecycle progression clearly visible.

Display structure

RUN
running
↓
policy.probe.allowed
↓
task.completed

Key visible fields

- run_id
- task_status
- actor
- last_event_kind
- terminal_event_kind

--------------------------------------------------

Milestone 4 — Event Log Legibility

Events readable without parsing raw JSON.

Success Conditions

- Events sorted by event timestamp
- Clear grouping per run
- Truncated JSON fields
- Human-readable timestamps

Example

policy.probe.run

running
policy.probe.allowed
task.completed

--------------------------------------------------

Milestone 5 — Probe Demo Path Clarity

Golden demo path must be visually obvious.

Example panel display

policy.probe.run
actor: policy.probe

status: completed
last_event: task.completed

--------------------------------------------------

Milestone 6 — Stable Refresh Behavior

Dashboard refresh must be predictable.

Success Conditions

- No duplicate rows
- No flickering order
- No partial renders
- Snapshot rows stable

--------------------------------------------------

Milestone 7 — Demo Readiness Confirmation

Fresh boot demonstration

1. System starts
2. Dashboard loads
3. Health endpoint visible
4. Probe run appears
5. Events populate
6. Terminal state visible

Operator confirmation

Probe → Allowed → Completed

--------------------------------------------------

Phase Completion Signal

System becomes demo-ready when a viewer can confirm:

System Healthy
policy.probe.run completed

within ~10 seconds of opening the panel.

