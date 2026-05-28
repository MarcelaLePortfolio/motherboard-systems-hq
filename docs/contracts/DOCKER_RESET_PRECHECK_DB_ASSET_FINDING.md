
# Docker Reset Precheck DB Asset Finding

## Status

Docker Desktop storage remains corrupted.

The live Docker Postgres volume could not be exported through `pg_dump`, `docker exec`, or `docker cp` because Docker returned input/output errors.

## External Assets Found

The backup inspection confirmed database-related assets outside Docker, including:

- `snapshots/postgres_snapshot_20251120_100809.tar.gz`

- multiple SQLite database backups under `snapshots/*/db`

- `agent_brain.db` backups

- local source backups

- Rio Drive source backups

## Meaning

Repo and GitHub state are safe.

Docker-only live volume data may still be unrecoverable through normal Docker CLI, but prior database assets exist outside Docker.

## Next Safe Action

Proceed with Docker Desktop factory reset only after accepting that the current corrupted live Docker volume may not be recoverable.

After reset, rebuild the Docker runtime from Git and available backup assets.

