Phase 30 — Canonical-ready contract checks + pretty DB doctor (current state)

Branch:

feature/phase30-canonical-contract

Checkpoint tags:

v30.1-phase30-canonical-ready-smoke-ok (pretty doctor fixed; strict contract check; smoke passes)

What we added:

server/worker/phase30_db_doctor_pretty.sh

Human-readable schema snapshot

Reports canonical readiness for dual-write events (payload_jsonb)

server/worker/phase30_contract_check.sql

Strict “canonical-ready” contract check (fails fast if required columns missing)

scripts/phase30_smoke_canonical_ready.sh

Runs: pretty doctor -> ensures payload_jsonb (runs phase29 migrator if needed) -> strict contract check -> deterministic worker smoke

How to verify:

POSTGRES_URL=... ./scripts/phase30_smoke_canonical_ready.sh
