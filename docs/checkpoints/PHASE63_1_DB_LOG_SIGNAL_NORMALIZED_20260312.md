# PHASE 63.1 DB LOG SIGNAL NORMALIZED
Date: 2026-03-12

## Summary

This checkpoint normalizes the general dashboard DB diagnostic logging so it reflects the actual runtime URL-based configuration.

## Reason

The dashboard runtime was already using a valid URL-based Postgres connection, but the general `[db] effective pool config` log output still reported parameter-style password fields like:

- `password_type: 'undefined'`
- `has_password: false`

This created a misleading signal even though runtime config was correct.

## Change Applied

Updated:

- `server.mjs`

The general DB diagnostic log now reports:

- URL-vs-params mode
- DB URL presence
- password status derived safely from the URL path when URL mode is active
- hidden password length/type when URL mode is active

## Safety

This is a logging-only correction.

It does not change:

- connection behavior
- layout structure
- metric bindings
- telemetry corridor behavior

## Verification

- `scripts/verify-phase63-telemetry-baseline.sh`
- `docker compose build dashboard`
- `docker compose up -d dashboard`
- `docker compose logs --tail=120 dashboard`
