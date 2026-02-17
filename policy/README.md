# Value Policy Authoring Rules (v1)

## Hard invariants
- Deterministic: no time, random, network, filesystem in evaluation.
- First-match wins: rules are evaluated in file order.
- Unknown action => tier=B and decision=deny (fail-safe).
- Context keys are whitelisted; unknown keys are rejected (fail-safe).
- Policy file is the single source of truth for tier classification.

## File format
- `policy_version` integer
- `defaults` with `unknown_action_tier` and `unknown_action_decision`
- `actions` registry (known action identifiers)
- `rules` ordered list:
  - `id`
  - `match` supports:
    - `action_id` (exact)
    - `action_prefix` (prefix match)
    - optional `context` exact matches (future; v1 evaluator may ignore until implemented)
  - `tier` in {A,B,C}
  - `decision` in {allow, deny, allow_with_conditions}
