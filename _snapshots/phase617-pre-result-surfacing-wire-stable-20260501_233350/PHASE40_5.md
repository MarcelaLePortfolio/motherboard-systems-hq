# Phase 40.5 — Shadow Audit Sampling (Audit-only)

## Goal
Reduce audit volume safely by adding optional sampling for policy audit capture, while preserving stdout as primary sink.

## In Scope
- Add env-gated sampling in policyAuditWrite:
  - POLICY_AUDIT_SAMPLE_PCT (0..100, default 100)
  - POLICY_AUDIT_SAMPLE_SEED (optional; stable hashing by task_id/run_id)
- Sampling affects file capture ONLY (POLICY_AUDIT_PATH), not stdout.
- Must not throw; audit-only; no enforcement changes.

## Non-Goals
- No schema changes
- No DB writes
- No policy decision changes

## Acceptance
- When SAMPLE_PCT=0: no file appends; stdout still prints.
- When SAMPLE_PCT=100: behavior unchanged.
- Deterministic sampling when SEED set (same task_id/run_id -> same sampled decision).
