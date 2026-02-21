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
    # Prefer likely "ops/dispatch" endpoints (more likely to be policy-gated than task creation).
    cat <<'PREF'
/api/ops/execute
/api/ops/run
/api/ops/confirm
/api/ops/enqueue
/api/queue/enqueue
/api/agent/dispatch
/api/dispatch
PREF
    # Then whatever the repo actually declares.
    extract_post_routes_from_source
    # Last resort fallbacks (include tasks but de-prioritized by ordering).
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

ENV_VAR="$(pick_enforce_var)"
echo "Using enforce var: ${ENV_VAR}"

echo "=== baseline: bring stack up (no enforce) ==="
docker compose up -d

echo
echo "=== wait for dashboard ==="
scripts/_lib/wait_http.sh "${DASH_URL}/api/runs" 60

DASHC="$(dashboard_container)"
if [[ -n "${DASHC:-}" ]]; then
  echo
  echo "=== confirm enforce env is NOT set in dashboard (baseline) ==="
  docker exec "$DASHC" sh -lc "env | grep -E '^${ENV_VAR}=' || true"
fi

# Try multiple payload shapes to find a request that is accepted (2xx) in baseline
# but blocked (401/403) under enforce with the exact same request.
PAYLOADS=(
  '{}'
  '{"probe":"phase48"}'
  '{"actor":"phase48.enforce.test","kind":"phase48.probe"}'
  '{"task_id":"phase48.enforce.block.probe"}'
  '{"run_id":"phase48.run.probe","task_id":"phase48.enforce.block.probe"}'
  '{"task_id":"phase48.enforce.block.probe","action_tier":"C","actor":"phase48.enforce.test","kind":"phase48.enforce.probe","payload":{"note":"expect block under enforce mode"}}'
)

echo
echo "=== differential enforcement check: find an endpoint+payload where baseline is 2xx and enforce becomes 401/403 ==="

found="0"
found_path=""
found_payload=""

# Baseline responses
declare -a baseline_rows=()
declare -a enforce_rows=()

for path in $(candidate_post_paths); do
  for payload in "${PAYLOADS[@]}"; do
    code0="$(probe_post_code "$path" "$payload")"
    baseline_rows+=("${path}\t${code0}")
    if [[ "$code0" =~ ^2[0-9][0-9]$ ]]; then
      # Now flip enforce on and re-probe same request.
      compose_up_with_enforce "$ENV_VAR" "1"
      scripts/_lib/wait_http.sh "${DASH_URL}/api/runs" 60 || true

      DASHC="$(dashboard_container)"
      if [[ -n "${DASHC:-}" ]]; then
        echo "=== confirm enforce env is set in dashboard ==="
        docker exec "$DASHC" sh -lc "env | grep -E '^${ENV_VAR}=' || true"
      fi

      code1="$(probe_post_code "$path" "$payload")"
      enforce_rows+=("${path}\t${code1}")

      if [[ "$code1" == "401" || "$code1" == "403" ]]; then
        found="1"
        found_path="$path"
        found_payload="$payload"
        break 2
      fi

      # flip back to baseline for next attempts
      compose_up_with_enforce "$ENV_VAR" ""
      scripts/_lib/wait_http.sh "${DASH_URL}/api/runs" 60 || true
    fi
  done
done

if [[ "$found" == "1" ]]; then
  echo
  echo "OK: enforcement blocks as expected"
  echo "baseline: POST ${found_path} => 2xx"
  echo "enforce : POST ${found_path} => 401/403"
  exit 0
fi

echo
echo "ERROR: could not prove enforcement via differential 2xx->401/403 transition." >&2
echo "Baseline probe matrix (path -> last seen code for a payload that was tested):" >&2
printf "%b\n" "${baseline_rows[@]}" | tail -n 80 >&2
echo >&2
echo "If needed, add a known-good payload for the protected endpoint you want to assert against into PAYLOADS above." >&2
exit 4
