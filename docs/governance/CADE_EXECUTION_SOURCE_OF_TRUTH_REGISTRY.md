
# Cade Execution Source of Truth Registry

Date: 2026-07-06

## Purpose

This registry defines the ONLY allowed sources of truth that may influence:

- execution_authorized

- preview_confirmed

- execution_plan.status

- confirmation_result

- EXECUTABLE state derivation

Any file not listed here is explicitly non-authoritative for execution control.

---

## 1. Primary Execution Switch Authority

- server/execution/matilda-execution-switch-evaluator.ts

Defines deterministic derivation of EXECUTABLE state.

---

## 2. Authorization Gate Authority

- server/execution/execution-approval-gate.mjs

Aggregates approval inputs and passes normalized state to switch evaluator.

---

## 3. Execution Planning Authority

- server/routes/matilda-execution-planning-route.ts

- db/matilda-execution-planning-runtime.ts

Defines execution_plan.status lifecycle.

---

## 4. Preview Authority Layer

- server/routes/matilda-preview-route.ts

- server/routes/matilda-preview-confirmation-route.ts

- db/matilda-preview-runtime.ts

- db/matilda-preview-confirmation-runtime.ts

Defines preview_confirmed state transitions.

---

## 5. Execution Authorization Authority

- server/routes/matilda-execution-authorization-route.ts

- db/matilda-execution-authorization-runtime.ts

Defines execution_authorized flag transitions.

---

## 6. Validation & Enforcement Boundaries (NON-AUTHORITATIVE)

These files may READ but may NOT DEFINE execution state:

- server/validation/*

- server/gate/*

- server/operational/*

- server/guards/*

- server/orchestrator/*

---

## 7. Hard Rule

If a file is not listed in sections 1–5:

- It MUST NOT define or mutate execution_authorized

- It MUST NOT define EXECUTABLE state logic

- It MAY only consume derived state

---

## 8. System Invariant

EXECUTABLE state is NEVER stored.

It is always derived.

