# Phase 39.1 — Value Alignment Layer 2 (Planning Only)
Policy Definition + Tier Assignment Authority

## Status
Planning only. No schema changes. No runtime behavior changes in this phase.

---

## Why this phase exists
Phase 39.0 introduced a value-gate concept (a “tier” gate) to prevent unsafe/unauthorized actions.
Phase 39.1 defines:
1) what a **policy** is (definition format + evaluation rules), and
2) who/what is allowed to **assign tiers** (authority model), so tiering cannot be arbitrarily changed by a rogue agent or accidental refactor.

This is a design layer that must be **deterministic, auditable, and versionable**.

---

## Scope
### In scope (design)
- A canonical **Policy Definition** format (versioned, diffable, deterministic).
- A canonical **Tier Model** (Tier A/B/C semantics + defaults).
- A **Tier Assignment Authority** model (who may set a tier, and how that assignment is authenticated/validated).
- Explicit invariants and acceptance criteria for later implementation phases.

### Out of scope (explicit)
- No DB/schema changes.
- No new endpoints.
- No worker behavior changes.
- No new signing infra / key management implementation (planning only).
- No UI.

---

## Definitions
### Tier
A coarse authorization classification for an action request.

**Recommended tiers (stable semantics):**
- **Tier A (Allowed by default, low-risk):**
  - Read-only introspection.
  - Idempotent “explain/plan” operations.
  - Non-destructive validations and dry-runs.
- **Tier B (Blocked by default, needs explicit grant):**
  - Mutations with bounded scope and clear rollback.
  - External calls (network) that can affect state outside the system.
  - Writes to files or repos that are not strictly phase-scoped.
- **Tier C (Blocked, exceptional):**
  - Irreversible/destructive actions.
  - Credential exfiltration, key material handling.
  - Production-impacting changes without gates.

**Default rule:** Unclassified == Tier B (fail-safe).

### Policy
A deterministic mapping:
- (action, context) → {allow | deny | allow-with-conditions}
plus:
- tier assignment rules
- required evidence / preconditions
- audit expectations

### Authority
A rule-set for “who can decide tiers / exceptions” and how the system validates that decision.

---

## Policy Definition (format + evaluation rules)
### Requirements
- **Static and versioned**: stored in repo, reviewed like code.
- **Deterministic**: no calls to time, random, network.
- **Diffable**: readable text (YAML/JSON/TOML). Prefer YAML or JSON.
- **Composable**: small rules; explicit precedence.
- **Explainable**: evaluation should produce a structured “why” trace.

### Proposed minimal shape (conceptual)
Policy file:
- `policy_version`
- `tiers` (definitions + defaults)
- `actions` registry (action identifiers)
- `rules` ordered list

Each rule:
- `id`
- `match` (action name + context predicates)
- `tier` (A/B/C)
- `decision` (allow/deny/allow_with_conditions)
- `conditions` (named checks; pure functions)
- `notes` (human intent, not executed)

### Evaluation order (deterministic)
1) Normalize input:
   - canonical action name
   - canonical context keys (sorted, no derived time)
2) Find first matching rule by order.
3) If no rule matches:
   - tier = default (Tier B)
   - decision = deny (or allow_with_conditions requiring explicit grant) — choose deny as safest default.
4) Produce an explanation trace:
   - matched rule id (or “none”)
   - computed tier
   - decision
   - unmet conditions (if any)

---

## Tier Assignment Authority (who can assign tiers)
### Problem
Even with a policy file, a rogue agent could attempt to:
- lie about the tier of an action,
- bypass the gate by mislabeling actions,
- claim “Tier A” for a Tier B/C operation.

We need a model where tier assignment is:
- **constrained by policy**
- **origin-authenticated**
- **auditable**
- **hard to spoof from inside the runtime**

### Two-layer model (recommended)
**Layer 1 — Policy-defined tier classification (primary):**
- The policy definition is authoritative for tier classification.
- Runtime computes tier from policy given (action, context).

**Layer 2 — Authority for exceptions (secondary):**
- If Tier B/C is requested to proceed, it requires an **explicit grant**.
- That grant must be validated as coming from an authorized entity (human/operator or a designated gatekeeper service).

This prevents agents from self-approving.

### Authority types (planning options)
Option A (simplest, local dev friendly):
- Grants provided via **environment variable** or **local file** (operator-controlled).
- Format: short-lived “grant tokens” listing permitted (action_id, run_id/task_id, scope, expiry).
- Pros: easy to implement, low infra.
- Cons: less robust; still acceptable for local/dev.

Option B (stronger, still no schema):
- Grants are **signed artifacts** (e.g., JSON + signature).
- Public keys are pinned in repo config.
- Runtime verifies signature offline.
- Pros: strong spoof resistance.
- Cons: requires key mgmt process later.

Option C (service-backed authority):
- Gatekeeper service issues signed grants, logs them, can enforce rate limits.
- Pros: best governance at scale.
- Cons: more moving parts; out of scope now.

### Recommended direction
Design for Option B compatibility from day one, implement Option A first if needed.
Invariants must make Option A “pluggable” with later replacement by signed grants.

---

## “Tier assignment authority” rule set (explicit)
### Who may assign / override?
- **Policy file** assigns baseline tiers. No runtime component may change that mapping.
- **Override authority** is external to agents:
  - Operator/human approval (primary)
  - Gatekeeper construct/service (secondary) — but only if it is itself locked by the same authority chain.

### What can be overridden?
- Only Tier B → allowed-with-conditions, or Tier C → still deny by default.
- Tier C should require a different pathway and explicit escalation policy (likely separate policy domain).

### Scope + expiry
Any override must be:
- scoped to a specific `run_id` or `task_id` (and optionally `attempt` / `epoch`)
- time-bounded (expiry)
- single-use by default (consumed once)

### Auditability
Even without schema changes, overrides must be:
- logged to stdout/stderr in a structured line
- attached to run metadata if/when run events exist (later phase)

---

## Threat model notes (planning)
We assume:
- Agents can generate arbitrary text/code suggestions.
- Agents could attempt to craft requests that look like Tier A.
- Agents could attempt to replay old approvals.

Therefore:
- Default deny for unknown actions.
- Policy decides tier (not the agent).
- Overrides must be origin-authenticated and scoped.
- Replay protection via expiry + nonce (future).

---

## Contract / invariants (must hold in implementation)
1) **Policy is the single source of truth** for tier classification.
2) **Unknown action == deny** (and Tier B default).
3) **No agent can self-authorize** Tier B/C operations.
4) **Override grants must be validated offline** (no network dependency required for validation).
5) **Deterministic evaluation**: same input → same output, no clock ambiguity.
6) **Explanation trace required** for every decision (debuggable + auditable).
7) **Policy changes are reviewable**: version bump + git diff.

---

## Implementation sketch (for future phases; not in this phase)
### Files
- `policy/value_policy.yaml` (or `.json`)
- `policy/README.md` (policy authoring rules)
- `server/policy/evaluate.*` (pure evaluator)
- `server/policy/grants.*` (grant validation adapter)

### Runtime flow (conceptual)
1) Build action request (action_id + normalized context)
2) Evaluate policy → (tier, decision, trace)
3) If decision allow → proceed
4) If decision deny but can be overridden:
   - validate grant
   - if valid → allow-with-conditions
5) Emit trace + decision to logs

---

## Acceptance criteria (for Phase 39.2 implementation gating)
- A unit test suite demonstrates:
  - unknown actions deny
  - deterministic evaluation
  - first-match precedence
  - baseline tier cannot be overridden by agent-provided input
- A “grant replay” test demonstrates expiry/nonce behavior (once implemented)
- A structured decision trace exists for every evaluation

---

## Next phase candidates (pick one)
- **Phase 39.2**: Implement policy evaluator (pure) + default policy file + trace output (still no schema).
- **Phase 39.3**: Implement grants (Option A initially) + enforcement wiring in the action execution path.
- **Phase 39.4**: Harden authority (Option B signatures) + pinned public keys + offline verification.

