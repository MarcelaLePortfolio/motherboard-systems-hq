# Container Authority Reconciliation Snapshot

Date: 2026-03-20

## Status
Reconciliation snapshot captured after Phase 95 golden.

## Active dashboard Dockerfile
`Dockerfile.dashboard`

Reason:
`docker-compose.yml` declares:

- service: `dashboard`
- build.dockerfile: `Dockerfile.dashboard`

## Active compose base
`docker-compose.yml`

Reason:
This is the base compose file containing the `dashboard` service definition and its build source.

## Active worker compose path(s)
Primary worker lane:
- `docker-compose.workers.yml`

Legacy / historical worker lanes still present:
- `docker-compose.worker.phase32.yml`
- `docker-compose.worker.phase34.yml`
- `docker-compose.phase31.7-worker.yml`

## Override files still in play
Dashboard / runtime / policy era overrides present in repo:
- `docker-compose.override.yml`
- `docker-compose.phase45_1.startup_determinism.yml`
- `docker-compose.phase46.dashboard_heap.override.yml`
- `docker-compose.phase47.enforce.override.yml`
- `docker-compose.phase47.postgres_url.override.yml`
- `docker-compose.phase54.enforce.override.yml`
- `docker-compose.phase54.postgres_bootstrap.override.yml`
- `docker-compose.phase54.shadow.override.yml`
- `docker-compose.phase57.shadow.env.override.yml`

## Safe next modification target
Safe bounded target:
- inspect and reconcile `Dockerfile.dashboard`
- inspect and reconcile `docker-compose.yml`
- inspect worker relationship through `docker-compose.workers.yml`

## Not safe yet
Do not modify:
- root `Dockerfile` as if it were the active dashboard authority
- compose topology broadly
- override stack behavior without explicit bounded scope
- worker lane assumptions without compose-path confirmation

## Current decision
This repo is already containerized.

The next safe move is not "containerize."
The next safe move is:
1. inspect `Dockerfile.dashboard`
2. inspect `docker-compose.yml`
3. inspect `docker-compose.workers.yml`
4. compare against current Phase 95 golden expectations
5. then choose one bounded container hardening change

