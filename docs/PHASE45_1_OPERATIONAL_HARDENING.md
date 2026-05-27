# Phase 45.1 — Operational Hardening & Startup Determinism

Goal: stabilize execution without changing architecture.

## What this adds
- Postgres healthcheck (pg_isready)
- Dashboard depends_on gate (postgres must be healthy)
- Canonical bring-up script
- Explicit non-zero exit if dashboard never becomes ready (`/api/runs` never returns HTTP 200)

## Canonical bring-up
From repo root:

```bash
scripts/phase45_1_up.sh
Options
	•	TIMEOUT_S=60 (default)
	•	DASH_URL=http://127.0.0.1:8080/api/runs (default)
