# Phase 37.2 — Terminal Kind Alignment Options (Planning Only)

## Protocols (hard)
- Planning-only docs.
- NO schema changes.
- NO view edits.
- NO worker changes.
- Canonical ordering definition for “latest” semantics:
  - `task_events.ts` ASC
  - tie-breaker: `task_events.id` ASC

## Inputs
- Authority: `PHASE37_RUN_VIEW_DEFINITION.sql`
- Validation lens: `PHASE37_ACCEPTANCE_CHECKS.sql` (§4a / §4b)

## Observed mismatch (fact)
- `run_view` terminal predicate (as captured): kinds in `('completed','failed','canceled','cancelled')`
- Acceptance lens terminal predicate (as written): kinds in `('task.completed','task.failed','task.cancelled')`

Result:
- Acceptance §4a/§4b can flag mismatches even when `run_view` matches its own definition.

---

## Alignment goal
Make the contract and its validation lens agree with the authoritative view *or* explicitly define a contract that the view must evolve toward, without ambiguity.

This document enumerates clean options.

---

## Option A — Acceptance lens matches current run_view (lowest-risk, aligns to authority)
Change acceptance terminal-kind set to match view:
- Terminal kinds: `('completed','failed','canceled','cancelled')`

Pros:
- Immediately makes §4a/§4b reflect what run_view actually does.
- Removes false-positive mismatches.

Cons:
- If the system intends `task.*`-namespaced kinds long-term, this “locks in” the current naming unless later revised.

---

## Option B — run_view matches acceptance lens (future-facing, would require view edit later)
Change run_view terminal-kind predicate to `('task.completed','task.failed','task.cancelled')`.

Pros:
- Aligns to the namespaced event-kinds implied by acceptance checks.

Cons:
- Requires a view edit (explicitly out-of-scope in Phase 37.2).
- May not match existing data.

---

## Option C — Dual-acceptance during migration (bridge)
Acceptance lens allows both namespaces:
- Terminal kinds: `('completed','failed','canceled','cancelled','task.completed','task.failed','task.cancelled')`

Pros:
- Minimizes migration pain; tolerates mixed historical data.

Cons:
- Weakens the contract unless time-boxed and later tightened.

---

## “Latest terminal event” selection rule alignment
Current view selection:
- `terminal_event` CTE: `DISTINCT ON (task_id, run_id) ... ORDER BY id DESC` (latest-by-id within task+run)

Acceptance §4a selection:
- `DISTINCT ON (run_id) ... ORDER BY ts DESC, id DESC` (latest-by-(ts,id) per run)

Potential options:
1) Acceptance matches view (latest-by-id within task+run), OR
2) View matches acceptance (explicit latest-by-(ts,id)), OR
3) Contract declares canonical latest-by-(ts,id) while view remains “implementation detail” until later phase.

Note:
- Phase 37 ordering rule already anchors canonical ordering to `(ts,id)`. If we keep that rule, Option (3) implies a future view change.

---

## Recommendation (planning-only)
- Decide the authoritative terminal-kind namespace (A/B/C).
- Decide whether Phase 37 contract’s “latest” definition is strictly `(ts,id)` (preferred) or “latest-by-id” (implementation).
- Once decided, Phase 37.3 can implement the minimal change (either acceptance SQL or view), with a golden tag before/after.

