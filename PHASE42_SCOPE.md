# Phase 42 — Scope (WIP)

## One hypothesis (single-scope PR)
Add a deterministic **scope gate** so Phase 42 PRs cannot merge while the scope doc still contains `PLACEHOLDER`.

## Why now
We repeatedly open PRs early (to preserve PR flow + CI), and we need a **contract-safe** way to prevent “empty scope” merges without adding product behavior.

## Invariants
- policy-clean main
- deterministic, repo-local checks (no UI inference)
- SQL-first semantics unchanged
- no worker/runtime behavior changes in this PR

## Acceptance (must be verifiable)
- `./scripts/phase42_scope_gate.sh` fails when `PHASE42_SCOPE.md` contains `PLACEHOLDER`
- the same script passes when no `PLACEHOLDER` remains
- CI runs the gate (via npm test wrapper or direct script execution) *OR* we run it as the required local pre-merge proof for this PR (explicitly documented in PR body)

## Smoke / proof
- `./scripts/phase42_scope_gate.sh` (deterministic grep gate)
