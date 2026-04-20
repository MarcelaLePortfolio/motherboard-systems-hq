# Phase 487 — Next Corridor Decision Frame

## Current State

System is STABLE.

All core surfaces:
- /tasks/recent ✅
- /logs/recent ✅
- /delegate ✅
- /matilda (fallback) ✅

No crashes.
No coupling issues.
No hidden blockers.

This is a **true checkpoint**.

---

## Corridor Selection Rule

Per protocol:

- Choose **ONE corridor**
- Do **NOT combine fixes**
- Do **NOT layer improvements**
- Each move must:
  - Solve a clearly identified gap
  - Stay within a single boundary
  - Be reversible

---

## OPTION 1 — Reintroduce Matilda (RECOMMENDED)

### Why this is the correct next move

Right now:

- System executes tasks
- System logs events
- System responds via API

BUT:

> The operator cannot **interact meaningfully**

Matilda is:
- The **operator interface**
- The **decision interpreter**
- The missing layer for Phase 487 stability

### Current gap
- Fallback only
- Module missing
- No response logic

### Goal
Restore:

POST /matilda → deterministic reply

### Scope (strict)
- Only fix module resolution
- Only restore handler
- No intelligence expansion yet

---

## OPTION 2 — Expand Delegate Schema

### What this does
Adds:
- agent
- payload
- result

### Risk
- Introduces schema coupling
- Touches write + read layers
- Not required for stability

### Verdict
❌ Not next

---

## OPTION 3 — Add Diagnostics Surface

### What this does
Adds:
GET /diagnostics/systemHealth

### Value
- Observability
- Debug clarity

### Limitation
- Does NOT improve operator interaction
- Secondary to Matilda

### Verdict
🟡 Can follow Matilda

---

## FINAL DECISION

### NEXT CORRIDOR:

> **Reintroduce Matilda (strict, minimal wiring only)**

---

## Execution Constraints

When we proceed:

- No schema changes
- No delegate changes
- No UI rewrites
- No multi-route edits

Only:

✔ Fix import path  
✔ Restore handler  
✔ Ensure deterministic reply  

---

## STOP CONDITION

Matilda must:

- Return 200
- Return a string reply
- Not crash
- Not depend on other systems

---

## After This Corridor

Next checkpoint options:

1. Diagnostics surface
2. Delegate enrichment

---

## Operator Guidance

You are no longer debugging chaos.

You are now:

> Executing controlled system evolution

One move at a time.

