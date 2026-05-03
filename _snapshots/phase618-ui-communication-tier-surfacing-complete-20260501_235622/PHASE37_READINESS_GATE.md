# Phase 37 — Readiness Gate (Pre-Implementation)

Branch: feature/phase37-0-planning
Mode: Still Planning Only

This file defines the **hard gate** that must be satisfied
before Phase 37.x (any implementation) may begin.

---

## 1️⃣ Provenance Complete

PHASE37_RUN_VIEW_PROVENANCE_MATRIX.md must:

- Have **no empty sections**
- Define Source(s) for every run_view column
- Define the exact SQL rule (copy-paste accurate)
- Explicitly state canonical “latest” semantics
- Explicitly define nullability expectations
- Explicitly define stability requirement

Gate condition:
> Every column must be mechanically explainable from SQL alone.

---

## 2️⃣ Determinism Verified (Read-Only)

Run:

    psql -f PHASE37_ACCEPTANCE_CHECKS.sql

Expected result:
- Zero rows from mismatch checks
- Zero “time travel” inconsistencies
- Zero terminal inconsistencies

Informational queries may return rows, but must be explainable.

---

## 3️⃣ No Hidden "Now()" Ambiguity

For any derived fields:
- lease_ttl_ms
- lease_fresh
- heartbeat_age_ms

You must document:
- What is the reference clock?
- Is it transaction time, statement time, or wall clock?
- Is it stable within a single SELECT?

Gate condition:
> The meaning of “now” is explicit and consistent.

---

## 4️⃣ Scope Confirmation

Before Phase 37.1 begins, confirm:

- No schema changes required, OR
- Any schema change is strictly additive and projection-safe
- No worker behavior depends on new projection logic

---

## 5️⃣ Revert Strategy Defined

If Phase 37.x implementation fails:

- Revert to golden tag:
  v36.4-phase36-run-list-observability
- Or revert to last green Phase 37 commit
- Do NOT layer speculative fixes

---

# 🚦 Implementation May Begin Only If:

☑ Provenance matrix fully filled  
☑ Acceptance SQL clean  
☑ “Now” semantics explicitly defined  
☑ No hidden state  
☑ Revert plan acknowledged  

Until then: documentation only.

