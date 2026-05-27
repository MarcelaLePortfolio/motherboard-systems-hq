#!/usr/bin/env bash
set -euo pipefail

BASE="${1:-http://127.0.0.1:8080}"

fail() { echo "🧯 $*" >&2; exit 2; }

echo "🔎 Verifying backend contract at: $BASE"

# ---- API endpoints (adjust if any differ) ----
check_code () {
  local path="$1"
  local want="${2:-200}"
  local code
  code="$(curl -sS -o /dev/null -w "%{http_code}" "$BASE$path" || true)"
  echo "$path -> HTTP $code"
  [[ "$code" == "$want" ]] || fail "Expected $want for $path, got $code"
}

# tasks list should return 200
check_code "/api/tasks" "200"

# chat endpoint is usually POST-only, so we just ensure it exists and isn't 404/500 via OPTIONS/HEAD
code="$(curl -sS -o /dev/null -X OPTIONS -w "%{http_code}" "$BASE/api/chat" || true)"
echo "/api/chat (OPTIONS) -> HTTP $code"
[[ "$code" != "404" && "$code" != "500" ]] || fail "/api/chat looks broken (HTTP $code)"

# ---- SSE endpoints (content-type must be text/event-stream) ----
check_sse () {
  local path="$1"
  local ct
  ct="$(curl -sSI "$BASE$path" | awk -F': ' 'tolower($1)=="content-type"{print tolower($2)}' | tr -d '\r')"
  echo "$path -> Content-Type: ${ct:-"(none)"}"
  [[ "$ct" == text/event-stream* ]] || fail "Expected text/event-stream for $path"
}

# If these aren’t exposed yet, comment them out until they are
check_sse "/events/tasks"
check_sse "/events/ops"

echo "🎉 Backend contract PASSED."
