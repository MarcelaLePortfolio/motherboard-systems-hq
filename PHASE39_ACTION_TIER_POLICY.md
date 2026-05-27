# Phase 39 — action_tier Policy Semantics + Enforcement Invariants (SQL-first)

## Purpose
Formalize **action_tier** semantics as a policy layer and ship **read-only** validation + deterministic smoke tests.
No worker logic changes in this phase. No schema changes unless strictly additive (none required here).

---

## Definitions

### action_tier
A categorical policy label that expresses **what the system is allowed to do** with a task/run, independent of implementation details.

Tiers (ordered from least risky to most risky):

- **TIER_A** — Read-only / observation / deterministic queries. Safe by default.
- **TIER_B** — Mutations that affect *only internal state* (DB writes, retries, scheduling, dispatch) but do not affect the outside world.
- **TIER_C** — External side effects (network calls, emails/SMS, payments, file writes outside controlled sandbox, calling third-party APIs, etc).

This is a policy taxonomy; enforcement can be layered (DB, server, worker), but Phase 39 delivers **contract + validation** only.

---

## Contract (Phase 39)
1. The system must be able to compute / assign a tier for every known task “kind” (or equivalent discriminator).
2. Any task kind with unknown tier is treated as **TIER_C** (fail-closed).
3. Tier assignment must be deterministic and declarative (SQL-first).
4. Validation must be read-only.
5. Deterministic smoke test required, runnable against dev DB.

---

## Enforcement Invariants (Read-only Validation)
These are enforced as *tests* in Phase 39:

### I1 — No Unknown Kinds
All distinct task kinds present in the DB must resolve to a tier via the policy mapping.

### I2 — Fail-Closed Default
If a kind is not mapped, it is treated as TIER_C and fails validation.

### I3 — Tier Stability
Tier mapping is stable within a single query (no time-dependent logic, no non-deterministic functions).

### I4 — Observability Completeness
Tier mapping query must produce:
- kind
- action_tier
- policy_source (mapped/default)
- reason (optional)

### I5 — Read-only Guarantee
Validation queries must not write or mutate anything (no INSERT/UPDATE/DELETE, no DDL).

---

## Policy Source of Truth (Phase 39)
SQL mapping lives in:
- `sql/policy/action_tier_policy.sql`

Validation lives in:
- `sql/policy/action_tier_validate.sql`

Deterministic smoke lives in:
- `scripts/phase39_action_tier_policy_smoke.sh`

---

## Notes
- If the project uses different column names than `kind`, the SQL scripts are written to discover the correct source via information_schema and will fail with a clear message if none exists.
- This phase is intentionally “contract only.” Future phases can wire enforcement into server/worker code once the contract is proven.
