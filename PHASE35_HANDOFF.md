# Phase 35 — Handoff (Golden Closed)

## Status
- **Phase 35 is closed and shipped on `main`.**
- Golden tags:
  - `v35.0-phase35-golden` = compose fix commit `33563b97e5347d77bb5261701a56bad5c650e0ed`
  - `v35.1-phase35-merge-golden` = merge commit on `main` `bd7f94ef125ac09264c66a0f21977cdb855400ce`
  - `v35.2-phase35-closure-docs` = closure note commit on `main` `78074ab9...`
- Docker verification (observed): task_events ids **2088–2091** show `task.running`/`task.completed` with `actor=docker-wA/docker-wB` and **non-NULL `run_id`**.
- Phase35 scratch stash is **anchored** locally as tag `stash-phase35-scratch-DO_NOT_APPLY` (points at `refs/stash` / commit `30b154b2...`).

## Canonical Compose Outcome
- `docker-compose.workers.yml` now parses cleanly (no duplicate YAML keys).
- `POSTGRES_URL` points to the **postgres service** host: `postgres://postgres:postgres@postgres:5432/postgres`.
- Owners are **templated**:
  - workerA: `WORKER_OWNER: ${WORKER_OWNER_A:-docker-wA}`
  - workerB: `WORKER_OWNER: ${WORKER_OWNER_B:-docker-wB}`
- `PHASE26_WORKER_ACTOR` intentionally unset/absent in canonical workers compose.

## Acceptance Invariants (interpreting results correctly)
- Treat **`run_id`** as the unit of work. A given `(actor, task_id)` can legitimately appear multiple times across different runs (e.g., reruns/reclaims).
- Must hold:
  - For docker events: **each `run_id` has ≤ 1 terminal** (`task.completed` or `task.failed`).
  - Optional strictness: `run_id` has exactly 1 `task.running` (if enforced).
- NOTE: A query grouping by `(actor, task_id)` and flagging `terminal_count > 1` can be a false-positive if it ignores `run_id`.

## Protocols (non-negotiable)
- **No scope creep**: only change what a failing invariant or log proves is necessary.
- **One issue per push**: next commit must directly address a known, reproducible failure.
- **3-strikes rule**: max 3 consecutive failed builds per hypothesis → then revert/reset to last known stable.
- **Golden tags are immutable**: never move existing golden tags; add new tags if needed.
- **Phase-scoped commits only**: exclude tmp/ scratch / debug artifacts unless explicitly part of the phase deliverable.
- **Stashes preserved** unless explicitly instructed otherwise.

## Quick Resume Commands
# Repo state + golden pointers
git status -sb
git log --oneline --decorate -n 15
git show -s --format='MAIN_HEAD=%H %s' main
git show -s --format='TAG_v35=%H %s' v35.0-phase35-golden
git show -s --format='TAG_merge=%H %s' v35.1-phase35-merge-golden
git show -s --format='TAG_docs=%H %s' v35.2-phase35-closure-docs

# Bring up stack (postgres via docker-compose.yml; workers via workers compose)
docker compose -f docker-compose.yml up -d postgres
docker compose -f docker-compose.workers.yml up -d
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}' | rg -n 'motherboard_systems_hq-(postgres|workerA|workerB)-1' || true

# Acceptance SQL (docker-only)
PG_CONT="$(docker ps --format '{{.Names}}' | awk '/motherboard_systems_hq-postgres-1/{print; exit} /postgres/{print; exit}')"
docker exec -i "$PG_CONT" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<'SQL'
\pset pager off
SELECT id, kind, task_id, actor, run_id, created_at
FROM task_events
WHERE actor LIKE 'docker-%'
  AND kind IN ('task.running','task.completed','task.failed')
ORDER BY id DESC
LIMIT 80;

SELECT run_id,
       COUNT(*) FILTER (WHERE kind IN ('task.completed','task.failed')) AS terminal_count,
       MIN(id) AS first_id,
       MAX(id) AS last_id
FROM task_events
WHERE actor LIKE 'docker-%'
  AND run_id IS NOT NULL
GROUP BY run_id
HAVING COUNT(*) FILTER (WHERE kind IN ('task.completed','task.failed')) > 1
ORDER BY terminal_count DESC, last_id DESC
LIMIT 50;
SQL

# Stash anchors (do not apply)
git stash list | sed -n '1,12p'
git show -s --format='TAG=%D%nCOMMIT=%H%nSUBJECT=%s' stash-phase35-scratch-DO_NOT_APPLY
