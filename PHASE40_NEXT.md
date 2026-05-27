# Phase 40 — SQL-First Action-Tier Claim Gate (Contract-Proof)

## Purpose
Make value-aligned decision control **structural** by enforcing Tier A-only claiming at the **SQL boundary** (not in JS).
This prevents accidental/rogue claim paths from executing Tier B/C work even if worker code drifts.

## In Scope (SQL-first)
1) **Single canonical SQL claim statement**
   - A single prepared SQL file (or function) that performs claim + lease with:
     - action_tier = 'A' (or Tier A allowlist)
     - status = 'queued'
     - attempts < COALESCE(max_attempts, <policy>)
     - deterministic ordering (id ASC or created_at ASC)
     - lease semantics unchanged (do not redesign)
   - Must be safe under concurrency (FOR UPDATE SKIP LOCKED or equivalent pattern already used)

2) **Contract artifacts**
   - `sql/phase40_claim_one_tierA.sql` (the canonical claim)
   - `scripts/phase40_tierA_claim_gate_smoke.sh`:
     - inserts Tier A + Tier B queued tasks
     - proves only Tier A can be claimed
     - proves Tier B remains queued
     - proves repeatability across workerA/workerB

3) **Acceptance checks**
   - `PHASE40_ACCEPTANCE_CHECKS.sql` validating:
     - no Tier B/C tasks ever transition to running via claim path
     - run_view / task_events consistency remains intact
     - no new terminal-kind mismatches

## Explicit Non-Goals
- No new agent capabilities
- No new UI
- No new scheduler logic
- No schema changes unless strictly additive and contract-safe (avoid if possible)

## Gate Conditions (merge criteria)
- Smoke script passes twice in a row on a clean db
- CI green
- Deterministic ORDER BY documented in the SQL
- Worker code references only the canonical SQL (no duplicate claim logic)

## Revert Strategy
- If any unexpected coupling appears, revert Phase 40 branch to last Phase 39 green tag/commit immediately.
