# Phase 704 — Direct run_view Restoration

The first run_view restoration attempt inspected the exported helper but did not invoke it.

This seal records direct restoration of the `run_view` schema through Postgres after the Docker data reset.

Verified:
- `run_view` was created directly in Postgres
- `\dv` lists `run_view`
- `select * from run_view limit 10` executes
- inspector-backed endpoints were probed after schema restoration
