# Phase 41 — Tier-A Canonical Claim Gate (Acceptance)

## Goal
Worker claim path is wired to `sql/phase40_claim_one_tierA.sql` as the canonical Tier-A gate.
All legacy claim SQL / JS claim paths are eliminated or disabled.

## Constraints
- No schema changes
- SQL-first
- One hypothesis per PR
- Golden tags immutable

## Evidence

### 1) Canonical-only claim wiring
- Any `PHASE*_CLAIM_ONE_SQL` defaults / compose wiring point to: `sql/phase40_claim_one_tierA.sql`.
- Any legacy `sql/phase*_claim_one*.sql` (except the canonical Tier-A SQL) hard-fails if invoked.

### 2) Worker smoke

Run:

    ./scripts/phase41_tierA_claim_gate_smoke.sh

Pass criteria:
- Tier A task is claimable (transitions away from `queued`).
- Tier B task remains `queued`.
