# Phase 11 – DB Task Endpoint Debug Notes

## Current DB State

- Docker Compose stack is running: dashboard + postgres.
- Postgres inspection shows:
  - POSTGRES_USER=user
  - POSTGRES_DB=motherboarddb
  - Role "user" exists with superuser + createdb privileges.
  - Databases present: motherboarddb, postgres, template0, template1.
- Helper scripts added:
  - scripts/db/create-postgres-role.sh
    - Ensures role "postgres" exists with LOGIN and password "password".
  - scripts/db/create-dashboard-db.sh
    - Ensures database "dashboard_db" exists (OWNER postgres).

## Recent Changes

- Successfully created role "postgres" in Postgres.
- Successfully created database "dashboard_db".
- /api/delegate-task-db is still returning 500 with a generic:
  - "Delegation failed due to server error."
  - Previously, we saw more specific DB errors:
    - "password authentication failed for user \"postgres\""
    - "database \"dashboard_db\" does not exist"

## Next Diagnostic Step

We need to capture the full Node/Express stack trace from inside the dashboard container when hitting:

- POST /api/delegate-task-db

to see whether the error is now:

- A connection string mismatch (wrong DB/user),
- A missing table / schema error,
- Or a logic error inside the DB-backed handler.

For this, we will:

1. Tail the dashboard container logs.
2. Tail the postgres container logs.
3. Immediately re-hit the /api/delegate-task-db endpoint and re-check logs.

These logs will guide the next safe change to either:
- Update the dashboard DB connection config, or
- Run the right schema/migration inside dashboard_db or motherboarddb, or
- Adjust the DB-backed route logic.

