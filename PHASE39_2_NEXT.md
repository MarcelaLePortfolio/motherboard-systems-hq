# Phase 39.2 — Policy Evaluator (Implementation Plan)
(Next Phase Handoff)

## One-liner handoff
Implement a pure, deterministic policy evaluator + default policy file + structured decision trace, with unit tests proving “unknown == deny” and “agents cannot self-tier,” and wire **nothing** into runtime enforcement yet.

---

## Goal
Create the **authoritative** tier/decision engine that later enforcement layers will call.

Deliverables:
- `policy/value_policy.yaml` (default policy, versioned)
- `policy/README.md` (authoring rules + invariants)
- Pure evaluator module (no IO, no time, no network)
- A structured decision trace object
- Unit tests for determinism + precedence + defaults

No schema changes.

---

## Non-goals
- No enforcement wiring into workers / routes yet (keep it pure + testable).
- No grant/override implementation yet (that’s Phase 39.3).
- No key management / signatures yet.

---

## Canonical inputs + outputs
### Input: `PolicyEvalRequest`
- `action_id` (string, normalized)
- `context` (object; only allowed keys; sorted deterministically; no derived time)
- `meta` (optional): `{ run_id?, task_id?, attempt?, epoch? }` (treated as data only)

### Output: `PolicyEvalResult`
- `tier`: `A | B | C`
- `decision`: `allow | deny | allow_with_conditions`
- `rule_id`: matched rule id or `null`
- `trace`:
  - `policy_version`
  - `matched` (boolean)
  - `matched_rule_id`
  - `default_applied` (boolean)
  - `reasons[]` (strings, stable ordering)
  - `conditions[]` (each with `{ id, ok, detail? }`)
  - `normalized` (canonical action + canonicalized context keys list)

---

## Determinism rules (hard)
- Evaluator must not call:
  - system clock (`Date.now`, `new Date`, SQL now)
  - random
  - network
  - filesystem
- Context canonicalization must be stable:
  - reject unknown keys (or bucket them into a stable “unknown” list, but prefer reject)
  - stable sort for keys / arrays where relevant
- Rule precedence is file order only.

---

## Policy file: minimum viable schema
- `policy_version: 1`
- `defaults`:
  - `unknown_action_tier: B`
  - `unknown_action_decision: deny`
- `tiers`: (optional descriptions)
- `actions`: registry of known `action_id`s (strings)
- `rules`: ordered list
  - `id`
  - `match`:
    - `action_id` (exact match) OR `action_prefix`
    - optional context predicates (exact match only; no regex in v1)
  - `tier`
  - `decision`
  - optional `conditions` (named, pure checks)

---

## Test gates (must pass)
1) Unknown `action_id` => `tier=B`, `decision=deny`, `rule_id=null`, `default_applied=true`
2) Known action with no matching rule => defaults apply
3) First-match wins (two rules match; earlier rule must apply)
4) Determinism: same input yields byte-identical JSON output (stable ordering)
5) “Agent cannot self-tier”: context containing `tier=A` or `requested_tier=A` must not affect tier unless policy explicitly matches/uses it (prefer to reject these keys outright)

---

## File layout (suggested)
- `policy/value_policy.yaml`
- `policy/README.md`
- `server/policy/evaluate.mjs` (or `.ts` if preferred in repo)
- `server/policy/schema.mjs` (minimal validation)
- `server/policy/__tests__/evaluate.test.*`

---

## Stop point
Phase 39.2 is complete when:
- tests pass locally
- policy file exists and is validated by the evaluator
- evaluator is callable from a small harness (test-only) and emits a stable trace
- no runtime execution paths are altered

