# Phase 47 — Decision Correctness (Claim / Lease / Reclaim)

This phase codifies SQL-first invariants for decision correctness and adds a fail-fast smoke script.
Promotion from shadow → enforce is gated behind these invariants and a golden tag.

## What is proven
Decision correctness is treated as: the DB event log + task row fields cannot simultaneously represent an impossible history.

SQL-first invariants cover:
- **Event monotonicity** per task by `(ts, id)`
- **Terminal consistency** between `tasks.is_terminal` and terminal-ish `task_events.kind`
- **Lease validity** for `task_status='running'` (owner, expiry, non-expired)
- **Reclaim contradiction detection**: multiple acquisitions without an intervening release marker
- **Heartbeat sanity** for running tasks relative to lease expiry

## How to run (fail-fast)
- `./scripts/phase47_smoke.sh`

This runs:
- `server/sql/phase47_decision_correctness_invariants.sql` (raises on any violation)

## Promotion: shadow → enforce
Only promote when:
1) Phase 47 smoke is green (local + CI, if applicable)
2) Existing shadow audit checks remain green
3) No schema drift is present (migrations applied, containers rebuilt)

Promotion mechanics (implementation-specific toggles):
- Shadow mode is audit-only. Enforce mode must fail closed on policy/lease violations.
- Flip the runtime flag(s) currently used by your codebase (examples often include):
  - `POLICY_SHADOW_ENABLED=0`
  - `POLICY_ENFORCE_ENABLED=1`
  - `PHASE34_ENABLE_LEASE=1` (if lease engine toggle exists)
Do not promote by changing multiple behaviors at once; keep the delta minimal.

## Golden tag
After promotion PR merges and smoke remains green:
- Create annotated tag: `v47.0-decision-correctness-golden`

## Rollback protocol (fast + reversible)
If enforce promotion causes regressions:
1) **Disable enforce** (re-enable shadow) via the same env toggle(s), redeploy.
2) If code change regression is confirmed:
   - `git revert <merge_commit_sha>` (single revert commit)
   - PR the revert, merge with required checks
3) Re-tag only after returning to a green baseline (never move a golden tag)

## Non-goals
- This phase does not add new schema.
- This phase does not change claim/lease logic; it proves correctness constraints and gates promotion.
