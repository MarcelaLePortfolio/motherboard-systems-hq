# Demo Hardening — Golden Demo Path Verification (Post-CI Green)

## Current state (source of truth)
- Branch: `main`
- Demo Hardening corridor: Phase 46 → Phase 57 stabilization
- PASSING: Phase 54 regression harness, Phase 55 lifecycle immutability invariant
- PASSING (main): build-and-test, ci-demo-hardening-smoke, ci-phase57-snapshot
- CLOSED: CI determinism, required checks naming/alias, schema/bootstrap in CI, no-psql proof path

## Guardrails
- Do not expand architecture.
- Do not introduce new features.
- Only close demo gaps and stabilize the golden demo path.
- Prefer UX/observability clarity improvements that do not change behavior.

## Goal
Make the orchestration panel **attractive, functioning, and observable** on a cold start:
- Fresh boot shows `run_view` + snapshot surface is present/stable
- Probe → visible run → live-ish events → policy gate visible → terminal state
- No manual psql, no manual schema patching

---

## The 3 remaining hardening tasks (precise, non-architectural)

### Task 1 — “Golden path story” visibility (panel narrative clarity)
**Problem:** The demo path may be *working* but not *understandable* at a glance.

**Deliverable:** The panel should make the golden story obvious:
1) **Probe happens** (explicitly visible)
2) **Run is created / visible** (run row appears)
3) **Events progress** (event stream shows movement)
4) **Policy gate shows** (shadow/enforce clearly labeled)
5) **Terminal state is obvious** (terminal kind + terminal flag is prominent)

**Acceptance checks (panel-level):**
- A first-time viewer can point to the screen and identify:
  - which run is the demo run
  - what state it is in now
  - what the last event was
  - whether policy is shadow/enforce and what that means visually
  - whether the run is terminal and why

**Constraints:**
- No new backend endpoints required.
- No new domain entities.
- Only presentational wiring, labels, ordering, grouping, highlighting, and “empty state” messaging.

---

### Task 2 — Stable dashboard cold start (deterministic first paint)
**Problem:** Cold start can look chaotic (layout jitter / unclear ordering / “empty then flood” / confusing default view).

**Deliverable:** A deterministic, calm cold-start experience:
- predictable default sort (most relevant run first)
- stable “loading vs empty” states
- no confusing flicker that makes the system look broken
- dashboard renders even if event streams are momentarily unavailable

**Acceptance checks:**
- After a fresh boot, the panel loads to a stable default view within a predictable window.
- No rapid resorting that reorders rows while the user is reading.
- Clear empty states (“no runs yet”, “waiting for first event”) without implying failure.

**Constraints:**
- No new features (e.g., advanced filters, new views, novel UX surfaces).
- Small UX stabilization only: default sort, pinned demo run, debounced refresh, consistent skeletons, improved empty-state copy.

---

### Task 3 — Run lifecycle visibility (operator-grade “what changed” signal)
**Problem:** Even with runs/events visible, it can be hard to see “what changed since last glance.”

**Deliverable:** Make lifecycle progress visually legible:
- show the transition points (created → running → terminal)
- show the most important fields prominently (terminal, last_event_kind, last_event_ts, actor)
- ensure the panel chooses the right “timestamp of record” consistently
- make terminal precedence visually unambiguous

**Acceptance checks:**
- When the terminal event occurs, the panel reflects terminal status without ambiguity.
- The “last event” shown is consistent with the system’s terminal precedence rules.
- The user can tell if the system is stuck vs progressing.

**Constraints:**
- Do not change lifecycle semantics or invariants.
- Only fix selection/display logic and presentation ordering.

---

## Golden Demo Path Verification Protocol (what we run + what we look for)

### A) Verify “fresh boot” surface is stable
**Observations to confirm (no psql):**
- Dashboard loads without manual intervention.
- `run_view` data is present in the API that backs the panel.
- Snapshot surface is present (whatever is displayed/queried by the panel and smoke).

### B) Trigger the golden demo sequence
**Expected viewer narrative:**
1) “System is healthy” (health indicator visible)
2) “Probe ran” (probe event visible)
3) “A run exists” (demo run appears)
4) “Events are streaming / updating” (last event advances)
5) “Policy gate is visible” (shadow/enforce clearly signaled)
6) “Run reaches terminal state” (terminal is unmissable)

### C) Validate “determinism”
- Repeat the above twice.
- The panel should look the same:
  - same default view
  - same ordering rules
  - same narrative cues
  - no chaotic reflow/jitter

---

## PR discipline (to avoid scope creep)
- One PR per task above.
- Each PR must:
  - include a clear before/after screenshot or screen recording note
  - include a short “acceptance checks” section (from above)
  - avoid introducing new endpoints or schema changes
  - avoid touching policy semantics

---

## Stopping point definition
We stop when:
- A cold boot produces a clean, understandable panel
- The golden story is visible end-to-end
- The run lifecycle is legible (progress vs stuck vs terminal)
- No manual DB actions are required

