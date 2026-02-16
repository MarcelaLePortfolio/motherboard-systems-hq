# Phase 43 — Governance Baseline + Self-Audit

## Purpose
Codify **main-pr-only** as the single authoritative ruleset for `main`, document its exact enforcement contract, and provide a lightweight audit proving:
- PR-only is enforced (no direct pushes)
- Required checks are enforced
- No approval requirement exists

This repo treats GitHub **Branch Protection** for `main` as the enforcement mechanism. This document is the canonical contract; the audit script is the proof.

---

## Enforcement Contract (authoritative)

### 1) Branch: `main`
- `main` is the **only** branch governed by this contract.
- The protected branch name is exactly: `main`

### 2) PR-only (no direct pushes)
`main` MUST have branch protection that prevents direct pushes by default.

Contract assertions:
- A branch protection rule exists for `main`
- `allow_force_pushes.enabled` is `false`
- `allow_deletions.enabled` is `false`

Interpretation:
- If the protection rule is missing, PR-only is not enforced.
- If force pushes or deletions are enabled, governance is considered degraded.

### 3) Required checks
`main` MUST require status checks before merge.

Contract assertions:
- `required_status_checks` exists (non-null)
- `required_status_checks.strict` is `true` OR the repo explicitly accepts non-strict (this contract prefers `true`)
- `required_status_checks.contexts` is non-empty OR GitHub reports required checks via `checks`/`contexts` fields (API-dependent)

Interpretation:
- If required checks are absent or empty, the “required checks” guarantee is not active.

### 4) No approval requirement
`main` MUST NOT require approvals/reviews to merge.

Contract assertions:
- `required_pull_request_reviews` is `null` OR disabled (API returns null when not required)

Interpretation:
- If PR reviews are required, this violates Phase 43 scope (“no approvals”).

---

## What this baseline does NOT cover
- Who is allowed to merge PRs (permissions / roles)
- CODEOWNERS-based review requirements
- Organization-level policies (outside this repo)
- CI workflow correctness (only that checks are required)
- Secret protection / DLP / signing / SLSA

---

## Proof Mechanism
Run:
- `./scripts/phase43_governance_audit.sh`

Expected result:
- Exit code 0 and a PASS summary with:
  - default branch is `main`
  - branch protection present
  - direct pushes restricted (no force pushes, no deletions)
  - required checks present and non-empty
  - approvals NOT required

---

## Operating Rule
If audit fails:
- Treat governance as **not enforced** until branch protection is corrected.
- Do not proceed with phases that assume safe/controlled merges to `main`.
