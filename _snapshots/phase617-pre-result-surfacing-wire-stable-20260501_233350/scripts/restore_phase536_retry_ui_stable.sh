#!/bin/bash
set -euo pipefail

TAG="${1:-phase536-retry-ui-one-command-restore}"
BRANCH="${RESTORE_BRANCH:-temp-fix-worker-heartbeat}"
SNAPSHOT_SQL="snapshots/phase536-retry-ui-stable/postgres_snapshot.sql"

echo "RESTORE TARGET: $TAG"
echo "RESTORE BRANCH: $BRANCH"

if [[ "${RESTORE_ALLOW_DIRTY:-0}" != "1" ]]; then
  if [[ -n "$(git status --short)" ]]; then
    echo "ERROR: working tree is not clean."
    echo "Commit/stash changes first, or rerun with RESTORE_ALLOW_DIRTY=1."
    git status --short
    exit 1
  fi
fi

git fetch origin --tags

if ! git rev-parse --verify "$TAG" >/dev/null 2>&1; then
  echo "ERROR: tag not found: $TAG"
  exit 1
fi

git switch "$BRANCH"
git reset --hard "$TAG"

if [[ ! -f "$SNAPSHOT_SQL" ]]; then
  echo "ERROR: snapshot SQL not found after restore: $SNAPSHOT_SQL"
  exit 1
fi

docker compose up -d postgres
sleep 3

docker compose exec -T postgres psql -U postgres -d postgres -v ON_ERROR_STOP=1 << 'SQL'
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;
SQL

docker compose exec -T postgres psql -U postgres -d postgres -v ON_ERROR_STOP=1 < "$SNAPSHOT_SQL"

docker compose up -d --build

sleep 3

echo ""
echo "RESTORE COMPLETE"
git status --short
git log --oneline -5
docker compose ps
