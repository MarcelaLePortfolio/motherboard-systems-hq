# Phase 44 — Enforcement Promotion (Planning Only)

## Purpose
Promote the already-proven **decision correctness** (Phase 41) into a **minimal, explicit enforcement surface** that:
- Preserves all Phase 41 invariants (no regressions; no weakening)
- Introduces enforcement only where explicitly enumerated
- Remains revertable to the last read-only golden baseline

## Start Point (Revert Target)
Golden tag / revert anchor:
- `v42.0-readonly-preserve-v41-gate-green`

## Definitions

### Decision Correctness (already proven)
Given the observable state (events / run_view projections), the system:
- Classifies scenarios deterministically (scenario matrix)
- Produces stable allow/deny decisions
- Keeps Phase 41 invariants clean

### Enforcement (to be promoted)
At a controlled boundary, **deny** disallowed mutations that violate the proven policy model.

Enforcement is *not* “more correctness”; it is *activation* of correctness in mutation paths.

## Non-Negotiables (Gate)
Phase 44 MUST:
- Preserve Phase 41 invariants
- Remain deterministic (no UI inference, no hidden state)
- Have a single, explicit enforcement boundary per mutation class
- Provide a clean kill-switch and safe rollback (tagged)

## Minimal Enforcement Surface (Choose One “First Boundary”)

Pick exactly ONE boundary for Phase 44 (do not broaden scope):
1) **Server write endpoints** (HTTP mutations): enforce at request boundary before state mutation
2) **Worker claim/transition** (task state transitions): enforce at the claim/transition boundary
3) **DB-level guard** (trigger / constraint): enforce centrally (highest risk; avoid unless necessary)

Recommendation for Phase 44 (minimal blast radius):
- Enforce at **server write endpoints** that already exist, with a strict, explicit allowlist.
- Leave worker enforcement for a later promotion phase unless required.

## Enforcement Modes (Kill-Switch)
Introduce an explicit runtime mode (single source of truth):

- `ENFORCEMENT_MODE=off`
  - No enforcement; baseline behavior (for local debugging only)
- `ENFORCEMENT_MODE=shadow`
  - Evaluate policy, log decision + reason, but do not block
- `ENFORCEMENT_MODE=enforce`
  - Block disallowed mutations with explicit, deterministic error

Default in production:
- Start with `shadow` during rollout, then promote to `enforce` only after acceptance.

## Where Enforcement Attaches (Enumerate Entry Points)

### A) Server mutation routes (existing)
Identify exact files/routes that mutate:
- `/api/tasks/create`
- `/api/tasks/complete`
- `/api/tasks/fail`
- `/api/tasks/cancel`
- `/api/tasks-mutations/*`
- `/api/artifacts` (if it writes)

Phase 44 policy hook should:
- Normalize input into a canonical “mutation intent”
- Compute decision (allow/deny + reason)
- Apply mode:
  - shadow: emit audit event/log line and continue
  - enforce: reject with 4xx and deterministic payload

### B) Worker transitions (defer unless required)
If needed, enforce at:
- claim
- transition -> running
- transition -> terminal
But only after server boundary is proven stable, unless workers bypass server entirely.

### C) DB-level enforcement (avoid in Phase 44)
Only if multi-writer bypass risk is unavoidable.
If used, must be additive and contract-safe.

## Policy Contract (What’s Being Enforced)
Policy inputs must be derived from:
- run_view (or canonical task_events projection)
- explicit request payload fields (no inferred state)

Policy outputs must be:
- allow/deny boolean
- stable reason code (string enum)
- stable “decision context” (subset of projection fields)

No new “clever” inference.

## Acceptance Criteria (What “Green” Means)

### Required Non-Regression
- Phase 41 gates remain green:
  - `scripts/phase41_invariants_gate.sh`
  - `scripts/phase41_smoke.sh`
  - scenario matrix dump remains consistent in meaning

### New Enforcement Acceptance (Phase 44)
Add a dedicated, phase-scoped smoke script proving:

1) **Allowed mutations succeed**
   - Known-good Tier A / allowed scenarios proceed
2) **Disallowed mutations fail deterministically**
   - Known-bad scenarios return:
     - HTTP status: 4xx (explicit)
     - body includes stable reason code
3) **Shadow mode logs without blocking**
   - Same disallowed scenario does not block but records decision
4) **Mode switch is the only control**
   - No hidden bypasses; mode must be explicit

### Rollback Proof
- A single command sequence can revert to `v42.0-readonly-preserve-v41-gate-green`
- CI remains green on revert

## Promotion Protocol
Phase 44 must be explicitly labeled as a promotion phase, and must include:
- Enumerated enforcement entry points (exact files + routes)
- A “no scope creep” statement
- A revert strategy (tag)
- A kill-switch description
- Acceptance scripts added in `scripts/`

## Open Questions (Must Be Answered Before Implementing)
- Which boundary is the *first* enforcement boundary (server vs worker)?
- What is the canonical “mutation intent” shape?
- Where does audit logging live (stdout vs table vs artifacts)?
- What are the stable reason codes?

## Deliverables (Phase 44 Implementation Phase)
- `PHASE44_SCOPE.md` (promotion phase scope)
- `scripts/phase44_scope_gate.sh`
- `scripts/phase44_enforcement_smoke.sh` (new acceptance)
- Minimal code changes attaching the policy hook to the chosen boundary
- Updated merge/tag record when green

