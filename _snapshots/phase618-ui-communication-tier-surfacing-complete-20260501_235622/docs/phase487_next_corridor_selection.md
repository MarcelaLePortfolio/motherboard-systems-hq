# Phase 487 — Next Corridor Selection

## Decision Lock

You are now required to select ONE corridor.

No parallel work.
No blending.
No drift.

## Available Corridors

### 1. Matilda Full Reintroduction
Restore:
- Ollama chat
- Delegation reasoning
- Agent-level intelligence

Risk Level: HIGH  
Reason: introduces external dependency + multi-layer coupling risk

---

### 2. Diagnostics Surface (RECOMMENDED)
Add:
- GET /diagnostics/systemHealth
- deterministic system visibility
- zero coupling to existing flows

Scope:
- read-only
- no DB mutation
- no route interference

Risk Level: LOW  
Reason: pure surface layer, no behavioral impact

---

### 3. Delegate Schema Expansion
Add:
- agent
- payload
- result fields

Risk Level: MEDIUM  
Reason: touches DB + write path (even if controlled)

---

## Recommendation

Proceed with:

> Diagnostics Surface

Why:

- strengthens visibility before complexity
- keeps system stable
- prepares for future debugging safely
- aligns with Phase 487 stabilization intent

---

## Execution Constraints (Carry Forward)

- No schema mutation
- No delegate changes
- No UI rewrites
- No multi-route edits

Only:

✔ Add isolated route  
✔ Return deterministic JSON  
✔ No external dependencies  

---

## Stop Condition

Diagnostics must:

- Return 200
- Return structured JSON
- Reflect real system state (basic)
- Not affect any existing route

---

## Operator Action

You must now explicitly confirm:

> "Proceed with Diagnostics"

Before any build begins.

