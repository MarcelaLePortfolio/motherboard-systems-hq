#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

COMPOSE_FILES=(
  -f docker-compose.yml
  -f docker-compose.workers.yml
)

export COMPOSE_PROJECT_NAME=motherboard_systems_hq

echo "== Fresh stack boot =="
docker compose "${COMPOSE_FILES[@]}" down --remove-orphans || true
docker compose "${COMPOSE_FILES[@]}" up -d --build

echo "== Wait for API health =="
for i in $(seq 1 45); do
  if curl -fsS http://127.0.0.1:8080/api/health >/dev/null 2>&1; then
    echo "API healthy"
    break
  fi
  if [ "$i" -eq 45 ]; then
    echo "ERROR: API health did not become ready"
    docker compose "${COMPOSE_FILES[@]}" ps || true
    exit 1
  fi
  sleep 1
done

echo "== Detect postgres service =="
PG_SERVICE="$(docker compose ps --services | grep -E 'postgres|db' | head -n1 || true)"
if [ -z "$PG_SERVICE" ]; then
  echo "ERROR: postgres service not found"
  docker compose "${COMPOSE_FILES[@]}" ps || true
  exit 1
fi
echo "PG_SERVICE=$PG_SERVICE"

echo "== Assert run_view exists =="
docker compose exec -T "$PG_SERVICE" psql -U postgres -d postgres -v ON_ERROR_STOP=1 -c \
"select 1 from run_view limit 1;" >/dev/null
echo "run_view OK"

echo "== Ensure policy.probe.run exists (fallback to Phase54 harness) =="
have_probe_run() {
  curl -fsS http://127.0.0.1:8080/api/runs | grep -q '"run_id"[[:space:]]*:[[:space:]]*"policy\.probe\.run"'
}

if have_probe_run; then
  echo "policy.probe.run already visible"
else
  echo "policy.probe.run not visible yet; running Phase54 regression harness (KEEP_STACK=1) to deterministically generate the demo path..."
  KEEP_STACK=1 bash scripts/phase54_regression_harness.sh

  # After harness, API should still be up; re-check with bounded retries.
  for i in $(seq 1 45); do
    if have_probe_run; then
      echo "policy.probe.run now visible"
      break
    fi
    if [ "$i" -eq 45 ]; then
      echo "ERROR: policy.probe.run still not visible after Phase54 harness"
      curl -sS http://127.0.0.1:8080/api/runs || true
      exit 1
    fi
    sleep 1
  done
fi

echo "== Demo smoke PASS (fresh boot → run_view present → policy.probe.run visible) =="
