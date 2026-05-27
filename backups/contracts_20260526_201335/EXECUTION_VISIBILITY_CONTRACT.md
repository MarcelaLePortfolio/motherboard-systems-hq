
# EXECUTION VISIBILITY CONTRACT

## 1. PURPOSE

This contract defines what execution-related information is allowed to be exposed to UI systems.

All execution state exists in backend systems only and must be explicitly filtered before reaching any presentation layer.

UI is not an execution observer. It is a result renderer.

---

## 2. CORE PRINCIPLE

Execution is always richer than what UI is allowed to see.

UI must never receive partial execution state that could imply internal system behavior.

---

## 3. ALLOWED UI EXECUTION STATES (STRICT ENUM)

The UI is ONLY permitted to observe the following task states:

- requested

- completed

- failed

No other execution states are valid for UI rendering.

---

## 4. FORBIDDEN UI STATES (ABSOLUTE)

The UI MUST NEVER display or infer:

- queued

- running

- in_progress

- delegating

- processing

- retrying

- BUSY / IDLE (agent-level execution inference)

- partial completion states

- intermediate pipeline stages

These are internal orchestration states only.

---

## 5. SSE / EVENT STREAM FILTERING RULE

All task events emitted via SSE or event buses must be normalized before reaching UI.

Event stream may contain rich lifecycle data internally, but UI-facing payload MUST be reduced to:

- requested (derived from task creation or delegation initiation)

- completed (derived from terminal success states)

- failed (derived from terminal error states)

No raw event kinds may be passed through.

---

## 6. AGENT STATUS EXCLUSION RULE

agent_status is explicitly excluded from UI execution interpretation.

agent_status may represent:

- assignment

- routing

- workload distribution

It does NOT represent execution progress.

UI must treat agent_status as informational metadata only.

---

## 7. TASK LIFECYCLE COLLAPSING RULE

All backend lifecycle complexity must collapse into one of:

- requested

- completed

- failed

This includes:

- DB transitions

- retry workflows

- orchestration pipelines

- worker execution states

- agent routing decisions

---

## 8. UI RESPONSIBILITY BOUNDARY

UI is responsible only for:

- displaying final task outcomes

- showing task existence

- rendering human-readable summaries

UI is explicitly NOT responsible for:

- interpreting execution state

- inferring system progress

- representing backend workflow stages

---

## 9. MATILDA / CADE COMPATIBILITY

Agent UI labels (Matilda, Cade) must comply with this contract:

- Matilda may show “thinking” (non-execution, UX-only)

- Cade may show routing intent (non-execution, UX-only)

- neither may expose execution pipeline state

---

## 10. NON-AUTHORITY GUARANTEE

No UI signal, agent label, or event stream field may override backend task status truth.

Backend task state remains the only source of truth for lifecycle interpretation.

---

## 11. DESIGN OUTCOME

This system intentionally enforces:

- high internal execution fidelity

- low external execution visibility

- strict collapse of lifecycle complexity at UI boundary

This prevents accidental exposure of orchestration semantics to users.

