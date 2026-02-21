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
  if [[ -n "$v" ]]; then
    echo "$v"
  else
    echo "POLICY_ENFORCE_ENABLED"
  fi
}

extract_post_routes_from_source() {
  # Best-effort extraction of POST /api/* routes from common server code patterns.
  # Outputs one path per line, like: /api/foo
  (
    git grep -nE '(\.post\(|router\.post\(|app\.post\()' -- server app src 2>/dev/null || true
  ) \
  | sed -nE 's/.*(app|router)?\.post\(\s*["'\''](\/api\/[^"'\''\s\)]+).*/\2/p' \
  | sed 's/[[:space:]]*$//' \
  | sort -u
}

pick_post_endpoint() {
  local candidates tmp
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' RETURN

  {
    # extracted from source (best)
    extract_post_routes_from_source

    # known/common fallbacks
    cat <<'CANDS'
/api/tasks
/api/task
/api/tasks/upsert
/api/tasks/create
/api/task-events
/api/task_events
/api/ops/dispatch
/api/ops/run
/api/ops/execute
/api/ops/confirm
/api/ops/enqueue
/api/queue/enqueue
/api/agent/dispatch
/api/dispatch
CANDS
  } | sed '/^$/d' | sort -u > "$tmp"

  while IFS= read -r path; do
    # Probe with a tiny JSON POST; 404 => not this endpoint; anything else => exists.
    local code
    code="$(
      curl -sS -o /dev/null -w "%{http_code}" \
        -H "content-type: application/json" \
        -X POST "${DASH_URL}${path}" \
        --data '{"probe":"phase48.endpoint.discovery"}' || true
    )"
    if [[ "$code" != "404" && "$code" != "000" ]]; then
      echo "$path"
      return 0
    fi
  done < "$tmp"

  return 1
}

ENFORCE_VAR="$(pick_enforce_var)"
echo "Using enforce var: ${ENFORCE_VAR}=1"

echo "=== restart stack with enforcement enabled ==="
env "${ENFORCE_VAR}=1" docker compose up -d --force-recreate

echo
echo "=== wait for dashboard ==="
scripts/_lib/wait_http.sh "${DASH_URL}/api/runs" 60

echo
echo "=== discover POST /api/* endpoint to test enforcement ==="
POST_PATH=""
if POST_PATH="$(pick_post_endpoint)"; then
  echo "Using POST endpoint: ${POST_PATH}"
else
  echo "ERROR: could not discover any POST /api/* endpoint (all probes returned 404/000)." >&2
  echo "Hint: run this to inspect POST routes found in source:" >&2
  echo "  git grep -nE '(app|router)\\.post\\(' -- server app src | sed -nE 's/.*post\\(\\s*[\"'\\'' ](\\/api\\/[^\"'\\''\\s\\)]+).*/\\1/p' | sort -u" >&2
  exit 2
fi

echo
echo "=== attempt an action expected to be blocked under enforcement ==="
payload='{"task_id":"phase48.enforce.block.probe","action_tier":"C","actor":"phase48.enforce.test","kind":"phase48.enforce.probe","payload":{"note":"expect block under enforce mode"}}'

code="$(
  curl -sS -o /dev/null -w "%{http_code}" \
    -H "content-type: application/json" \
    -X POST "${DASH_URL}${POST_PATH}" \
    --data "$payload" || true
)"

case "$code" in
  401|403|409|422) echo "OK: blocked as expected (HTTP $code)"; exit 0 ;;
  404) echo "ERROR: discovered endpoint became 404 at request time (HTTP 404)." >&2; exit 3 ;;
  200|201|202) echo "ERROR: enforcement did not block (HTTP $code) at ${POST_PATH}." >&2; exit 4 ;;
  000) echo "ERROR: no HTTP response (000). Dashboard may have restarted/crashed." >&2; exit 5 ;;
  *) echo "ERROR: unexpected response (HTTP $code). Treat as failure until verified." >&2; exit 6 ;;
esac
