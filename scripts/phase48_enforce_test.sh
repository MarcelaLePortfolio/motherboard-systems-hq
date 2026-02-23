#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

DASH_URL="${DASH_URL:-http://127.0.0.1:8080}"
ENV_VAR="POLICY_ENFORCE_ENABLED"

dashboard_container() {
  docker ps --format '{{.Names}}' | grep -E '(^|-)dashboard-1$' | head -n1 || true
}

compose_up_with_enforce() {
  local k="$1"
  local v="${2:-}"
  if [[ -n "$v" ]]; then
    env "$k=$v" docker compose up -d --force-recreate
  else
    env "$k=" docker compose up -d --force-recreate
  fi
}

post_code() {
  local path="$1"
  curl -sS -o /dev/null -w "%{http_code}" \
    -H "content-type: application/json" \
    -X POST "${DASH_URL}${path}" \
    --data '{}' || true
}

assert_env_in_dashboard() {
  local want="$1"
  local c
  c="$(dashboard_container)"
  : "${c:?dashboard container not found}"
  local got
  got="$(docker exec "$c" sh -lc "env | grep -E '^${ENV_VAR}=' | head -n1 || true")"
  echo "$got"
  if [[ "$want" == "1" ]]; then
    [[ "$got" == "${ENV_VAR}=1" ]] || { echo "ERROR: ${ENV_VAR} not set to 1 in dashboard" >&2; exit 10; }
  else
    [[ "$got" == "${ENV_VAR}=0" || -z "$got" ]] || { echo "ERROR: ${ENV_VAR} not baseline (0/empty) in dashboard" >&2; exit 11; }
  fi
}

echo "=== baseline: enforce OFF, /api/policy/probe must be 200 ==="
docker compose up -d
scripts/_lib/wait_http.sh "${DASH_URL}/api/runs" 60
assert_env_in_dashboard "0"
c0="$(post_code "/api/policy/probe")"
[[ "" == "201" ]] || { echo "ERROR: expected 201 baseline from /api/policy/probe, got ${c0}" >&2; exit 20; }
echo "OK: baseline probe 200"

echo
echo "=== enforce ON, /api/policy/probe must be 403 ==="
compose_up_with_enforce "$ENV_VAR" "1"
scripts/_lib/wait_http.sh "${DASH_URL}/api/runs" 60 || true
assert_env_in_dashboard "1"
c1="$(post_code "/api/policy/probe")"
[[ "$c1" == "403" ]] || { echo "ERROR: expected 403 under enforce from /api/policy/probe, got ${c1}" >&2; exit 21; }
echo "OK: enforce probe 403 (blocked as expected)"
