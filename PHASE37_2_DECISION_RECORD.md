# Phase 37.2 — Decision Record (Fill Before Phase 37.3)

## Protocols
- This is a **planning-only** decision record.
- No schema changes.
- No view edits.
- No worker changes.
- Canonical ordering for “latest” semantics (Phase 37): `task_events.ts` ASC, tie-breaker `task_events.id` ASC.

---

## Decision 1: Terminal-kind namespace alignment
Choose exactly one:

- [ ] Option A — Acceptance lens matches `run_view` (bare kinds): `completed|failed|canceled|cancelled`
- [ ] Option B — `run_view` matches acceptance lens (`task.*` kinds): `task.completed|task.failed|task.cancelled`
- [ ] Option C — Dual-accept during migration: allow both namespaces (time-boxed)

**Selected:** ________________________________________

**Rationale (1–3 sentences):**
______________________________________________________________________________
______________________________________________________________________________

---

## Decision 2: “Latest terminal event” selection rule
Choose exactly one:

- [ ] Canonical `(ts,id)` (preferred; consistent with Phase 37 ordering rule)
- [ ] Latest-by-id (match current `run_view` terminal CTE ordering)
- [ ] Bridge: acceptance tolerates both, but contract commits to canonical `(ts,id)` by Phase ___

**Selected:** ________________________________________

**Rationale (1–3 sentences):**
______________________________________________________________________________
______________________________________________________________________________

---

## Implementation target for Phase 37.3 (must be explicit)
Choose exactly one:

- [ ] Update acceptance SQL only (contract lens aligns to current view)
- [ ] Update view only (view aligns to contract lens)
- [ ] Update both in one phase (only if strictly necessary)

**Selected:** ________________________________________

**Non-goals reminder:**
- No schema changes
- No worker changes
- No unrelated refactors

