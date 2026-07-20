# 04 — Architecture Principles

## Purpose

This document defines implementation-independent architectural invariants for the frontend rebuild.

These principles apply regardless of framework, component structure, routing strategy, or visual design.

Any implementation that violates these principles should be considered architecturally incorrect, even if it is technically functional.

---

## Architectural Invariants

### 1. Backend Truth Is Authoritative

The frontend reflects backend truth.

It does not manufacture it.

---

### 2. Interpretation Remains Separate From Execution

User intent, interpretation, authorization, delegation, and execution are distinct concepts.

The frontend must preserve these distinctions.

---

### 3. Governance Remains Observable

Governance state should remain visible wherever it materially affects user understanding or system behavior.

---

### 4. Authority Is Never Inferred

Authority must always originate from explicit backend state.

The frontend must never infer permission from context, previous actions, cached state, or visual affordances.

---

### 5. Unknown Information Remains Unknown

Missing information should remain explicitly unresolved until confirmed.

The interface should communicate uncertainty rather than fabricate certainty.

---

### 6. Recovery Is First-Class

Recovery is a core lifecycle capability, not an exceptional afterthought.

Recovery state should remain observable when supported by backend contracts.

---

### 7. Reconciliation Is Observable

Reconciliation is part of the engineering lifecycle.

Its progress and outcome should remain distinguishable from execution.

---

### 8. Outcome Review Remains Distinct

Outcome review represents evaluation of completed work.

It should not be merged with execution status or authorization.

---

### 9. Components Remain Reusable

Reusable reference modules should remain reusable.

Project-specific behavior should be introduced through composition rather than unnecessary modification whenever practical.

---

### 10. Presentation Never Manufactures State

Visual presentation must accurately communicate backend state.

Styling, animations, optimistic updates, or placeholder content must never imply backend truth that has not been confirmed.

---

### 11. Safe Degradation

When backend information becomes unavailable, malformed, stale, or rejected, the frontend should degrade safely while preserving truthful communication.

---

### 12. Explicit Boundaries

The frontend should preserve clear boundaries between:

- Observation
- Guidance
- Recommendation
- Approval
- Delegation
- Execution
- Recovery
- Reconciliation
- Outcome Review

These responsibilities should not be visually or functionally collapsed without explicit architectural justification.

---

## Guiding Philosophy

The rebuilt frontend should optimize for clarity, trustworthiness, explainability, and governance rather than minimizing implementation effort.

Correctness of architectural behavior takes precedence over convenience of implementation.
