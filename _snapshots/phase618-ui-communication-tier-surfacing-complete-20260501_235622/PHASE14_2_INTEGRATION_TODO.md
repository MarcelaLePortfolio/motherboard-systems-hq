# Phase 14.2 — Integration checklist (safe + incremental)

Status:
- taskContract.mjs exists
- No runtime behavior changed yet (by design)

Next steps (DO THESE ONE AT A TIME):

## 1) Locate task routes
Search for task writes:
- POST /api/tasks
- POST /api/delegate-task
- POST /api/complete-task
- any PUT/PATCH task endpoint

Command:
  rg "api/.*task" server public

---

## 2) Wire normalization (non-breaking)
For each write endpoint:
- import { normalizeTask } from "./taskContract.mjs"
- wrap incoming payload:
    const task = normalizeTask(req.body)

DO NOT enforce transitions yet.

---

## 3) Enforce validation (create only)
After normalize:
- call validateNewTask(task)
- on error:
    return res.status(400).json({ ok:false, error: err.message })

---

## 4) Enforce transitions (update only)
Before updating status:
- call validateTransition(prev.status, next.status)

---

## 5) SSE hygiene (later phase)
Ensure SSE emits normalized task only.

Guardrails:
- One endpoint per commit
- If UI breaks → revert immediately
