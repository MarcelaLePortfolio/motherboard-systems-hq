# PHASE 62B TASK EVENTS DB LOG SIGNAL NORMALIZED
Date: 2026-03-12

## Summary

This checkpoint normalizes the task-events DB diagnostic logging so it reflects the actual runtime URL-based configuration.

## Reason

The dashboard runtime was already using a valid URL-based Postgres connection, but the task-events log output was still reporting raw parameter fields like:

- `password_type: 'undefined'`
- `has_password: false`

This created a misleading signal even though compose and runtime config were correct.

## Change Applied

Updated:

- `server/routes/task-events-sse.mjs`

The task-events pool diagnostic log now reports:

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
- workspace wiring

## Rule

If presentation, runtime, or structure regresses:
1. restore stable checkpoint
2. verify layout contract
3. verify metric binding contract
4. rebuild cleanly

Never fix forward.
