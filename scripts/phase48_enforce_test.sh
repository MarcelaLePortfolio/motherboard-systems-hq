#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

DASH_URL="${DASH_URL:-http://127.0.0.1:8080}"

# Heuristic: discover enforce env var used by the codebase; fall back to POLICY_ENFORCE_ENABLED=1.
# We keep this resilient by scanning tracked files for obvious candidates.
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

ENFORCE_VAR="$(pick_enforce_var)"

echo "Using enforce var: ${ENFORCE_VAR}=1"

echo "=== restart stack with enforcement enabled ==="
# We rely on docker compose reading .env for POSTGRES_URL; we only toggle enforce in-process here.
# If services already run, this will recreate with updated env.
env "${ENFORCE_VAR}=1" docker compose up -d --force-recreate

echo
echo "=== wait for dashboard ==="
scripts/_lib/wait_http.sh "${DASH_URL}/api/runs" 60

echo
echo "=== attempt an action expected to be blocked under enforcement ==="
# Minimal assumption: POST /api/tasks exists and returns 4xx when blocked.
# We send a clearly "high-risk" tier request; adjust server-side mapping as needed.
payload='{"task_id":"phase48.enforce.block.probe","action_tier":"C","actor":"phase48.enforce.test","kind":"phase48.enforce.probe","payload":{"note":"expect block under enforce mode"}}'

code="$(
  curl -sS -o /dev/null -w "%{http_code}" \
    -H "content-type: application/json" \
    -X POST "${DASH_URL}/api/tasks" \
    --data "$payload" || true
)"

# Accept common "blocked" codes; fail if it looks allowed.
case "$code" in
  401|403|409|422) echo "OK: blocked as expected (HTTP $code)"; exit 0 ;;
  404) echo "ERROR: /api/tasks not found (HTTP 404) — adjust endpoint for your runtime." >&2; exit 2 ;;
  200|201|202) echo "ERROR: enforcement did not block (HTTP $code)." >&2; exit 3 ;;
  *) echo "ERROR: unexpected response (HTTP $code). Treat as failure until verified." >&2; exit 4 ;;
esac
