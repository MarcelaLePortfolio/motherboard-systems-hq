# Phase 39 — Value Alignment (Machine-Enforceable Minimum Spec)

This spec defines a **minimal, machine-enforceable** values layer that can be proven via deterministic tests.
It is intentionally narrow: only what can be enforced at runtime without ambiguity.

## Definitions

### Action Tier
A task may be assigned an `action_tier`:

- **Tier A**: Allowed for autonomous runtime processing.
- **Tier B**: Disallowed for autonomous runtime processing (requires human approval / separate pathway).
- **Tier C**: Disallowed for autonomous runtime processing (never autonomous).

### Enforced Invariant (Hard Gate)
**Workers MUST NOT autonomously mutate state as a result of encountering Tier B/C.**
Specifically:
- A Tier B/C task must not be claimed.
- A Tier B/C task must not transition status.
- A Tier B/C task must not increment attempts.
- A Tier B/C task must not create/append task_events.

### Required Observable
When a Tier B/C task is encountered during the claim cycle, the worker must emit a deterministic log line:
- Prefix: `VALUE_GATE_REFUSE`
- Fields: `task_id`, `action_tier`

This log is the only required side-effect for Tier B/C at this stage.

## Implementation Contract

### Claim Path
The worker claim operation is permitted to:
- **Read** queued tasks.
- **Lock** a candidate row (`FOR UPDATE SKIP LOCKED`) inside the claim transaction.

But it must:
- **Refuse Tier B/C without update**.
- **Only update/claim Tier A (or NULL tier treated as A)**.

### No Schema Changes
This phase introduces **no schema changes**. (Any future additions must be strictly additive.)

## Deterministic Proof (Smoke Test)
A smoke script must prove:
1) A Tier B (or C) queued task triggers `VALUE_GATE_REFUSE` in worker logs.
2) The task row remains unchanged (status/claimed_by/attempts).
3) No task_events are added by the worker for that task_id.
