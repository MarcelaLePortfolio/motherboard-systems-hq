# Phase 43 — Governance Baseline + Self-Audit

## Purpose
Codify **main-pr-only** as the single authoritative ruleset for `main`, document its exact enforcement contract, and provide a lightweight audit proving:
- PR-only is enforced (no direct pushes)
- Required checks are enforced
- No approval requirement exists

GitHub can enforce these controls via:
- **Repository Rulesets** (modern rules engine), and/or
- **Classic branch protection**.

This document is the canonical contract; the audit script is the proof.

---

## Enforcement Contract (authoritative)

### 1) Branch: `main`
- `main` is the **only** branch governed by this contract.
- The protected branch name is exactly: `main`

### 2) PR-only (no direct pushes)
`main` MUST block direct pushes (changes must flow through a pull request).

Contract assertions (must hold via rulesets and/or classic protection):
- A governance policy exists that requires changes via PR for `main`
- Force pushes are disabled
- Branch deletions are disabled

Interpretation:
- If PR-only is not enforced, governance is considered broken for `main`.

### 3) Required checks
`main` MUST require the status check:
- `ci/build-and-test`

Contract assertions:
- The required check `ci/build-and-test` is enforced for merges to `main`
- Whether enforcement is via rulesets or classic protection is implementation detail

Interpretation:
- If `ci/build-and-test` is not required, the “required checks” guarantee is not active.

### 4) No approval requirement
`main` MUST NOT require approvals/reviews to merge.

Contract assertions:
- No rule requires PR reviews/approvals

Interpretation:
- If PR reviews are required, this violates Phase 43 scope (“no approvals”).

---

## Proof Mechanism
Run:
- `./scripts/phase43_governance_audit.sh`

Expected result:
- Exit code 0 and a PASS summary with:
  - default branch is `main`
  - PR-only enforced for main
  - required check `ci/build-and-test` enforced
  - approvals NOT required

---

## Operating Rule
If audit fails:
- Treat governance as **not enforced** until repo rules are corrected.
- Do not proceed with phases that assume safe/controlled merges to `main`.
