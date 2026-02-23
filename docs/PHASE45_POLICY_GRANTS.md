# Phase 45: auditable policy_grants (override authority model)

## What this phase adds
- `server/sql/phase45_policy_grants.sql` (idempotent DDL)
- `server/policy/policy_grants.ts` (deterministic grant resolver)
- `scripts/phase45_regression_policy_grants.sh` (applies SQL + proves expiry semantics)

## Active semantics
Active grants are those where:
- `expires_at IS NULL OR expires_at > now()`

## Integration contract (next)
Evaluator computes decision for `(subject, scope)` then:
- if decision is deny/block and allow-overrides are permitted for that scope:
  - `resolvePolicyGrant({ subject, scope, want: "allow" })`
  - if hit: flip decision to allow and attach grant evidence to audit payload
- optionally, if decision is allow and deny-grants are permitted:
  - `resolvePolicyGrant({ subject, scope, want: "deny" })`
  - if hit: flip decision to deny and attach grant evidence
