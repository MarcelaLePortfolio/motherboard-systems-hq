# Phase 47 — Local Enforce Toggle (docker compose)

This repo uses `server/policy/policy_flags.mjs` to read env flags:

- `POLICY_SHADOW_MODE` (shadow on when `"1"`)
- `POLICY_ENFORCE_MODE` (enforce on when `"1"`)

Local enforce (minimal-delta) uses a compose override that only sets env:
- `POLICY_SHADOW_MODE=0`
- `POLICY_ENFORCE_MODE=1`

## Run
Use your normal compose files plus the Phase 47 enforce override:

- `docker compose -f docker-compose.yml -f docker-compose.workers.yml -f docker-compose.phase47.enforce.override.yml up -d --build`

Then verify:
- `./scripts/phase47_smoke.sh`

## Rollback
Remove the override file from the command line (or set enforce=0, shadow=1) and redeploy/restart.
