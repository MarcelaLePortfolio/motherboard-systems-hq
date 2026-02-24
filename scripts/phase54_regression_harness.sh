#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
PROBE_PATH="${PROBE_PATH:-/api/policy/probe}"
WAIT_PATH="${WAIT_PATH:-/api/runs}"

ensure_default_network() {
  local net="motherboard_systems_hq_default"
  local lbl

  if docker network inspect "$net" >/dev/null 2>&1; then
    lbl="$(docker network inspect -f '{{ index .Labels "com.docker.compose.network" }}' "$net" 2>/dev/null || true)"
    if [[ "$lbl" != "default" ]]; then
      docker network rm "$net" >/dev/null 2>&1 || true
    fi
  fi

  if ! docker network inspect "$net" >/dev/null 2>&1; then
    docker network create --label com.docker.compose.network=default "$net" >/dev/null
  fi
}

compose_up() {
  local mode="$1"
  docker compose down --remove-orphans >/dev/null 2>&1 || true

  ensure_default_network

  if [[ "$mode" == "shadow" ]]; then
    docker compose -f docker-compose.yml -f docker-compose.workers.yml -f docker-compose.phase47.postgres_url.override.yml -f docker-compose.phase54.shadow.override.yml up -d --build
  elif [[ "$mode" == "enforce" ]]; then
    docker compose -f docker-compose.yml -f docker-compose.workers.yml -f docker-compose.phase47.postgres_url.override.yml -f docker-compose.phase54.enforce.override.yml up -d --build
  else
    echo "ERROR: unknown mode: $mode" >&2
    exit 2
  fi

  if [[ -x scripts/_lib/wait_http.sh ]]; then
    scripts/_lib/wait_http.sh "${BASE_URL}${WAIT_PATH}" 90
  else
    for _ in {1..90}; do
      code="$(curl -sS -o /dev/null -w "%{http_code}" "${BASE_URL}${WAIT_PATH}" || true)"
      [[ "$code" != "000" ]] && break
      sleep 1
    done
  fi
}

compose_down() {
  docker compose down --remove-orphans
}

pg_container() {
  local id
  id="$(docker compose ps -q postgres 2>/dev/null || true)"
  if [[ -n "${id}" ]]; then
    echo "${id}"
    return 0
  fi
  if docker ps --format '{{.Names}}' | grep -q '^motherboard_systems_hq-postgres-1$'; then
    echo "motherboard_systems_hq-postgres-1"
    return 0
  fi
  echo "ERROR: cannot locate postgres container" >&2
  docker compose ps >&2 || true
  exit 3
}

pg_defaults() {
  local pgc="$1"
  local user db
  user="$(docker exec "${pgc}" sh -lc 'printf "%s" "${POSTGRES_USER:-postgres}"')"
  db="$(docker exec "${pgc}" sh -lc 'printf "%s" "${POSTGRES_DB:-postgres}"')"
  echo "${user} ${db}"
}

pg_count_table() {
  local table="$1"
  local pgc user db
  pgc="$(pg_container)"
  read -r user db < <(pg_defaults "${pgc}")
  docker exec "${pgc}" sh -lc "psql -U \"${user}\" -d \"${db}\" -Atc \"select count(*) from ${table};\""
}

assert_num_eq() {
  local a="$1" b="$2" label="$3"
  if ! [[ "$a" =~ ^[0-9]+$ && "$b" =~ ^[0-9]+$ ]]; then
    echo "ERROR: non-numeric compare for ${label}: a=${a} b=${b}" >&2
    exit 6
  fi
  if (( a != b )); then
    echo "ERROR: expected ${label} (${a}) == (${b})" >&2
    exit 7
  fi
}

http_code_of_probe() {
  curl -sS -o /dev/null -w "%{http_code}" -X POST "${BASE_URL}${PROBE_PATH}" || true
}

run_mode_case() {
  local mode="$1"
  local expect_code="$2"
  local expect_writes="$3"

  echo "=== Phase 54: ${mode} case ==="
  compose_up "${mode}"

  local before_tasks before_events after_tasks after_events code
  before_tasks="$(pg_count_table "tasks")"
  before_events="$(pg_count_table "task_events")"

  code="$(http_code_of_probe)"
  echo "probe_http_code=${code}"

  if [[ "${code}" != "${expect_code}" ]]; then
    echo "ERROR: expected probe HTTP ${expect_code}, got ${code} (${mode})" >&2
    compose_down
    exit 10
  fi

  after_tasks="$(pg_count_table "tasks")"
  after_events="$(pg_count_table "task_events")"

  echo "tasks_before=${before_tasks} tasks_after=${after_tasks}"
  echo "task_events_before=${before_events} task_events_after=${after_events}"

  if [[ "${expect_writes}" == "writes" ]]; then
    if (( after_tasks <= before_tasks && after_events <= before_events )); then
      echo "ERROR: expected writes in shadow mode (no increase in tasks or task_events)" >&2
      compose_down
      exit 11
    fi
  elif [[ "${expect_writes}" == "no_writes" ]]; then
    assert_num_eq "${after_tasks}" "${before_tasks}" "tasks_count_no_change (${mode})"
    assert_num_eq "${after_events}" "${before_events}" "task_events_count_no_change (${mode})"
  else
    echo "ERROR: unknown expect_writes: ${expect_writes}" >&2
    compose_down
    exit 12
  fi

  compose_down
}

main() {
  run_mode_case "shadow" "201" "writes"
  run_mode_case "enforce" "403" "no_writes"
  echo "OK: Phase 54 regression harness passed (shadow=201+writes, enforce=403+no-writes)."
}

main "$@"

dump_phase54_debug() {
  echo
  echo "=== Phase 54 debug: docker compose ps ==="
  docker compose ps || true
  echo
  echo "=== Phase 54 debug: dashboard logs ==="
  docker compose logs --no-color --tail=200 dashboard || true
  echo
  echo "=== Phase 54 debug: postgres logs ==="
  docker compose logs --no-color --tail=120 postgres || true
}
trap dump_phase54_debug EXIT
