
# PHASE 719 — DISABLE INVALID LEGACY SCRIPTS

## PURPOSE

Remove active loading of two invalid legacy frontend scripts that are creating browser console syntax errors.

## ERRORS ADDRESSED

1.

`phase61_recent_history_wire.js:1 Uncaught SyntaxError: Illegal return statement`

Cause:

- file begins with top-level `return`

- loaded as a normal script

- invalid JavaScript execution path

2.

`dashboard-graph.js:2 Uncaught SyntaxError: Unexpected token 'export'`

Cause:

- file contains ESM `export`

- loaded as a normal deferred script

- invalid browser execution mode for current include

## CHANGE

Remove these active script includes from `public/index.html`:

- `js/phase61_recent_history_wire.js`

- `js/dashboard-graph.js`

## SAFETY

This does not delete either file.

This does not modify:

- worker artifact generation

- artifact persistence

- retry/requeue behavior

- task execution routes

- preview API route

- iframe artifact rendering

- database schema

## CLASSIFICATION

Frontend console hygiene only.

