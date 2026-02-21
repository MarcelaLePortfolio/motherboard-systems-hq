#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

DASH_URL="${DASH_URL:-http://127.0.0.1:8080}"

pick_enforce_var() {
  local v=""
  v="$(git grep -nE '\bpolicyEnforceEnabled\b|\bPOLICY_ENFORCE\b|\bENFORCE_MODE\b|\bPHASE[0-9]+_POLICY_ENFORCE\b' -- \
      server app src scripts 2>/dev/null \
    | sed -nE 's/.*\b(PHASE[0-9]+_POLICY_ENFORCE|POLICY_ENFORCE_ENABLED|POLICY_ENFORCE|ENFORCE_MODE)\b.*/\1/p' \
    | head -n1 || true)"
  if [[ -n "$v" ]]; then echo "$v"; else echo "POLICY_ENFORCE_ENABLED"; fi
}

dashboard_container() {
  docker ps --format '{{.Names}}' | grep -E '(^|-)dashboard-1$' | head -n1 || true
}

extract_post_routes_from_source() {
  (
    git grep -nE '(\.post\(|router\.post\(|app\.post\()' -- server app src 2>/dev/null || true
  ) \
  | sed -nE 's/.*(app|router)?\.post\(\s*["'\''](\/api\/[^"'\''\s\)]+).*/\2/p' \
  | sed 's/[[:space:]]*$//' \
  | sort -u
}

candidate_post_paths() {
  {
    cat <<'PREF'
/api/ops/execute
/api/ops/run
/api/ops/confirm
/api/ops/enqueue
/api/queue/enqueue
/api/agent/dispatch
/api/dispatch
PREF
    extract_post_routes_from_source
    cat <<'FALL'
/api/tasks/create
/api/tasks/upsert
/api/tasks
FALL
  } | sed '/^$/d' | awk '!seen[$0]++'
}

probe_post_code() {
  local path="$1"
  local payload="$2"
  curl -sS -o /dev/null -w "%{http_code}" \
    -H "content-type: application/json" \
    -X POST "${DASH_URL}${path}" \
    --data "$payload" \
    --connect-timeout 2 --max-time 6 \
    || echo "000"
}

compose_up_with_enforce() {
  local enforce_var="$1"
  local enforce_val="$2" # "1" or "" (unset)
  if [[ -n "$enforce_val" ]]; then
    env "${enforce_var}=${enforce_val}" docker compose up -d --force-recreate
  else
    env -u "${enforce_var}" docker compose up -d --force-recreate
  fi
}

assert_env_present_in_dashboard() {
  local var="$1"
  local want="$2" # 0/1
  local c
  c="$(dashboard_container)"
  : "${c:?dashboard container not found}"
  local got
  got="$(docker exec "$c" sh -lc "env | grep -E '^${var}=' || true")"
  if [[ "$want" == "1" ]]; then
    if [[ -z "$got" ]]; then
      echo "ERROR: ${var} was not present inside dashboard container; compose is not wiring env through." >&2
      echo "Hint: ensure docker-compose.yml dashboard service includes:" >&2
      echo "  environment:" >&2
      echo "    - ${var}=\${${var}:-0}" >&2
      exit 20
    fi
  fi
}

ENV_VAR="$(pick_enforce_var)"
echo "Using enforce var: ${ENV_VAR}"

echo "=== baseline: bring stack up (no enforce) ==="
docker compose up -d
scripts/_lib/wait_http.sh "${DASH_URL}/api/runs" 60

# Baseline may or may not show the var; don't fail baseline.
c0="$(dashboard_container || true)"
if [[ -n "${c0:-}" ]]; then
  echo "=== baseline env (dashboard) ==="
  docker exec "$c0" sh -lc "env | grep -E '^${ENV_VAR}=' || true"
fi

PAYLOADS=(
  '{}'
  '{"probe":"phase48"}'
  '{"actor":"phase48.enforce.test","kind":"phase48.probe"}'
  '{"task_id":"phase48.enforce.block.probe"}'
  '{"run_id":"phase48.run.probe","task_id":"phase48.enforce.block.probe"}'
  '{"task_id":"phase48.enforce.block.probe","action_tier":"C","actor":"phase48.enforce.test","kind":"phase48.enforce.probe","payload":{"note":"expect block under enforce mode"}}'
)

echo "=== differential enforcement check: find endpoint+payload where baseline is 2xx and enforce becomes 401/403 ==="

found="0"
found_path=""
declare -a baseline_rows=()

for path in $(candidate_post_paths); do
  for payload in "${PAYLOADS[@]}"; do
    code0="$(probe_post_code "$path" "$payload")"
    baseline_rows+=("${path}\t${code0}")
    if [[ "$code0" =~ ^2[0-9][0-9]$ ]]; then
      compose_up_with_enforce "$ENV_VAR" "1"
      scripts/_lib/wait_http.sh "${DASH_URL}/api/runs" 60 || true

      # Fail-fast: enforce var MUST be present in-container for the test to mean anything.
      assert_env_present_in_dashboard "$ENV_VAR" "1"

      code1="$(probe_post_code "$path" "$payload")"
      if [[ "$code1" == "401" || "$code1" == "403" ]]; then
        found="1"
        found_path="$path"
        break 2
      fi

      compose_up_with_enforce "$ENV_VAR" ""
      scripts/_lib/wait_http.sh "${DASH_URL}/api/runs" 60 || true
    fi
  done
done

if [[ "$found" == "1" ]]; then
  echo "OK: enforcement blocks as expected"
  echo "baseline: POST ${found_path} => 2xx"
  echo "enforce : POST ${found_path} => 401/403"
  exit 0
fi

echo "ERROR: could not prove enforcement via 2xx->401/403 transition." >&2
echo "Baseline probe matrix (tail):" >&2
printf "%b\n" "${baseline_rows[@]}" | tail -n 120 >&2
exit 4
