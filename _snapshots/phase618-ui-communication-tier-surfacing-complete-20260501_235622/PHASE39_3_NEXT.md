# Phase 39.3 — Override Grants (Authority) (Plan)
(Next Phase Handoff)

## One-liner handoff
Add an override-grant adapter (Option A first) that can authorize Tier B actions **only** with an explicit, scoped, expiring grant, and produce a structured audit line—still without schema changes.

---

## Goal
Introduce an **external-to-agent** mechanism to allow certain Tier B actions to proceed *when explicitly authorized*.

Phase 39.2 provided:
- policy file
- pure evaluator
- trace + determinism tests

Phase 39.3 adds:
- grant validation (Option A: local operator-controlled artifact)
- decision combinator: (policy decision + grant) -> final decision
- auditable structured log line

---

## Non-goals
- No schema changes.
- No network authority service yet.
- No cryptographic signatures yet (Option B is Phase 39.4).
- No broad runtime wiring; if any wiring occurs, it must be behind a noop-disabled flag and remain read-only by default.

---

## Grant model (Option A)
### Source
Operator-controlled file or env var:
- file: `policy/grants.json` (gitignored) OR
- env: `MB_GRANTS_JSON`

### Shape
- `grants[]` list, each:
  - `id` (string)
  - `allow_actions` (list of action_id or prefixes)
  - `scope` (one of: run_id, task_id; required)
  - `scope_id` (string; required)
  - `expires_at` (RFC3339 string) OR `ttl_seconds` from time-of-load (choose one; evaluator must not call time)
  - `single_use` (bool; default true) — enforcement of consumption deferred until schema exists; still log intent
  - `notes` (string)

### Key constraint
The **policy evaluator stays pure**.
Grant loading/expiry checking happens in a thin adapter that can call time, but must:
- pass a boolean `grant_ok` plus details into a pure combine function, OR
- accept an injected `now_ms` argument from caller (for determinism in tests).

---

## Combining logic (hard)
- If policy decision == allow => allow
- If policy decision == deny:
  - only Tier B may become allow_with_conditions via grant
  - Tier C remains deny (even with Option A grant)
- Every “grant used” path must emit an audit record:
  - action_id
  - tier
  - policy_rule_id
  - grant_id
  - scope + scope_id
  - expires_at
  - result decision

---

## Tests (must pass)
1) Tier B deny becomes allow_with_conditions when a valid scoped grant exists
2) Grant with wrong scope_id does nothing (still deny)
3) Expired grant does nothing
4) Tier C never becomes allowed via Option A grant
5) Audit record emitted in a stable JSON form (use stableStringify)

---

## File layout (suggested)
- `server/policy/grants.mjs` (load + validate grants)
- `server/policy/combine.mjs` (pure combination logic)
- `server/policy/__tests__/grants.test.mjs`
- `server/policy/__tests__/combine.test.mjs`
- `policy/grants.example.json`
- `.gitignore` entry for `policy/grants.json`

---

## Stop point
Phase 39.3 ends when:
- grant validation exists + tested
- combine logic exists + tested
- audit record format locked
- no schema changes introduced

