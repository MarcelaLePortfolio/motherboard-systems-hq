# Phase 25 — Authority & Orchestration Lock (Contract)

Branch baseline: `feature/phase24-orchestration-polish` @ `4e164c6a`

This document is the **contract-first** definition for system authority and orchestration. No Phase-24 cleanup or refactors may proceed until these invariants are accepted and enforced.

---

## 1) Glossary

- **task_events**: The append-only event log table representing the authoritative lifecycle of tasks.
- **Task**: A logical unit of work with a stable `task_id` and an event-driven lifecycle.
- **Writer**: The sole component allowed to **mutate** the authoritative state (i.e., insert into `task_events` and any derived authoritative tables, if any).
- **Consumers**: UI/SSE/dashboard and read-model builders that may **only** derive views from persisted events.
- **UI inference**: Any lifecycle assumption made by UI without an authoritative persisted event.
- **Event row id**: DB primary key / row identifier for an event row. **Never** a task identifier.

---

## 2) Authority: Single Source of Truth

### 2.1 Authoritative lifecycle signal
**task_events is the single authoritative lifecycle signal.**

Allowed authority:
- Lifecycle truth exists only if supported by persisted `task_events`.

Disallowed authority:
- UI state, SSE state, process uptime, logs, or any other signal.

### 2.2 UI must not infer lifecycle
UI must not:
- invent lifecycle states
- treat absence as completion
- treat disconnects as failure
- create task IDs from row IDs

UI may:
- render explicit “unknown / awaiting authoritative signal” states

---

## 3) One Writer Rule

### 3.1 Single writer component
Exactly one component may mutate lifecycle state by inserting into `task_events`.

Forbidden:
- UI, SSE endpoints, dashboards writing lifecycle events directly.

### 3.2 Determinism & idempotency
Writer must:
- support idempotency
- prevent duplicate semantic events

---

## 4) Identity Rules

### 4.1 Task identifiers
- `task_id`: logical, stable
- `run_id`: execution instance

### 4.2 Forbidden identifiers
Must not be used as `task_id`:
- event row IDs
- DOM/UI IDs
- timestamps
- SSE message IDs

### 4.3 Required event fields
Each event must include:
- `ts`
- `task_id`
- `run_id`
- `kind`
- `actor`
- optional `msg`, `meta`

---

## 5) Event Taxonomy

### Canonical kinds
- `task.created`
- `task.queued`
- `task.started`
- `task.progress`
- `task.blocked`
- `task.completed`
- `task.failed`
- `task.canceled`

### Terminal rule
After terminal:
- no further lifecycle events allowed

---

## 6) Orchestration Invariants

### 6.1 State derivation
Lifecycle state is derived by folding events in order.

### 6.2 Valid transitions
- created → queued → started → progress* → terminal
- queued → started | canceled
- started ↔ blocked

Invalid:
- terminal → non-terminal
- progress before started

### 6.3 Implicit creation
Optional, but must be consistent if allowed.

### 6.4 Multi-run semantics
- multiple runs per task
- UI must respect run boundaries

### 6.5 Ordering
- `ts` is canonical
- folds must be deterministic

### 6.6 No UI-driven lifecycles
UI may request actions, never assert outcomes.

---

## 7) Deduplication

Writer must dedupe semantically identical events.

---

## 8) SSE Contract

- SSE transports persisted events only
- disconnects never imply lifecycle changes

---

## 9) Phase-24 Cleanup Gate

Blocked until:
1. Single writer enforced
2. No UI inference
3. No row-id task IDs
4. Deterministic fold exists
5. Terminal invariants enforced
6. Idempotency implemented

---

## 10) Acceptance Checklist

- [ ] Contract committed
- [ ] Writer named
- [ ] UI audited
- [ ] Tests encode invariants

