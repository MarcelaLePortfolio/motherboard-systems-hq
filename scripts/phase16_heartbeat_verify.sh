set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
echo "== Phase 16 – Heartbeat Verify =="
echo "BASE_URL=$BASE_URL"
echo

need_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 1; }; }
need_cmd curl
need_cmd tr
need_cmd grep

echo "1) /dashboard loads (HTTP 200) ..."
status="$(curl -sS -o /dev/null -w "%{http_code}" "$BASE_URL/dashboard")"
[[ "$status" == "200" ]] || { echo "FAIL: /dashboard HTTP $status" >&2; exit 1; }
echo "OK"
echo

echo "2) bundle contains sse-heartbeat-shim import ..."
bundle="$(curl -sS "$BASE_URL/bundle.js" | tr -d '\r')"
echo "$bundle" | grep -q 'sse-heartbeat-shim' || {
  echo "FAIL: bundle.js does not reference sse-heartbeat-shim" >&2
  exit 1
}
echo "OK"
echo

echo "3) /events/tasks content-type is text/event-stream (timeout-safe) ..."
hdrs="$(curl -sS --max-time 3 -D - -o /dev/null "$BASE_URL/events/tasks" | tr -d '\r' || true)"
echo "$hdrs" | grep -qi '^content-type: text/event-stream' || {
  echo "FAIL: /events/tasks missing Content-Type: text/event-stream (or timed out)" >&2
  echo "--- headers ---" >&2
  echo "$hdrs" >&2
  exit 1
}
echo "OK"
echo

echo "✅ Phase 16 verify script complete."
echo
echo "Manual: open DevTools Console on $BASE_URL/dashboard and run:"
echo "  window.__HB && window.__HB.snapshot()"
