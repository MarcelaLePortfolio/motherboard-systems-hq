# Phase 16 – Debug Notes (Ops HB + Tasks DB Auth)

## Symptom: Tasks widget shows `password authentication failed for user "postgres"`
Cause: Postgres official image only applies `POSTGRES_PASSWORD` on the very first database init.
If the volume already exists, changing env vars later does **not** change the DB user's password.

Fix:
- Determine what password the dashboard is using (PGPASSWORD/POSTGRES_PASSWORD)
- Then run inside the postgres container:
  `ALTER USER postgres WITH PASSWORD '<that password>';`

## Symptom: `/api/heartbeat` shows ops.ts not advancing
Note: ops.ts advances only when `/api/ops-heartbeat` is hit.
The dashboard pinger should call `/api/ops-heartbeat` periodically, but manual checks must hit it too.

Quick check:
- GET `/api/ops-heartbeat`
- then GET `/api/heartbeat` and confirm ops.ts moved forward.

## Sanity Checks
- Tasks SSE stream should include a `data:` snapshot (no `event: error`)
- `bundle.js` should reference `ops-heartbeat-pinger`
