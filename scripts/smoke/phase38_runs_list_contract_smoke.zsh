#!/usr/bin/env zsh
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
RUNS_URL="${RUNS_URL:-$BASE_URL/api/runs}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "ERROR: missing dependency: $1" >&2; exit 2; }; }
need curl
need jq

tmp_hdr="$(mktemp)"
tmp_body="$(mktemp)"
cleanup() { rm -f "$tmp_hdr" "$tmp_body"; }
trap cleanup EXIT

# Preflight: fail fast if unreachable.
set +e
http_code="$(
  curl -sS --connect-timeout 2 --max-time 8 \
    -D "$tmp_hdr" -o "$tmp_body" -w '%{http_code}' \
    -H 'Accept: application/json' \
    "$RUNS_URL"
)"
curl_rc="$?"
set -e

if [[ "$curl_rc" -ne 0 ]]; then
  echo "ERROR: cannot reach $RUNS_URL (curl rc=$curl_rc). Is the API reachable at $BASE_URL ?" >&2
  exit 1
fi

if [[ "$http_code" != "200" ]]; then
  echo "ERROR: expected 200 from $RUNS_URL, got $http_code" >&2
  echo "=== response headers ===" >&2
  sed -n '1,120p' "$tmp_hdr" >&2 || true
  echo "=== response body (first 2000 chars) ===" >&2
  head -c 2000 "$tmp_body" >&2 || true
  echo >&2
  exit 1
fi

# Content-Type must include json
ct="$(awk -F': ' 'BEGIN{IGNORECASE=1} tolower($1)=="content-type"{print tolower($2)}' "$tmp_hdr" | head -n1 | tr -d '\r')"
if [[ -z "$ct" || "$ct" != *"application/json"* ]]; then
  echo "ERROR: expected Content-Type to include application/json; got: ${ct:-<missing>}" >&2
  echo "=== response headers ===" >&2
  sed -n '1,120p' "$tmp_hdr" >&2 || true
  exit 1
fi

# Contract assertions for /api/runs response shape:
# expected envelope: { ok: true, count: number, rows: array<object> }
jq -e '
  type=="object"
  and (has("ok") and (.ok==true))
  and (has("count") and (.count|type=="number"))
  and (has("rows") and (.rows|type=="array"))
' "$tmp_body" >/dev/null

# rows element shape: require stable core keys; avoid asserting optional fields
jq -e '
  (.rows | length == 0) or
  (all(.rows[]; type=="object")
   and all(.rows[]; has("run_id") and (.run_id|type=="string" and length>0))
   and all(.rows[]; has("task_id") and (.task_id|type=="string" and length>0))
   and all(.rows[]; has("task_status") and (.task_status|type=="string" and length>0))
  )
' "$tmp_body" >/dev/null

# count must match rows length (strict)
jq -e '(.count|floor) == (.rows|length)' "$tmp_body" >/dev/null

# no duplicate run_id in the payload
jq -e '
  (.rows|length == 0) or
  ((.rows|map(.run_id)|length) == (.rows|map(.run_id)|unique|length))
' "$tmp_body" >/dev/null

echo "OK: /api/runs contract stable at $RUNS_URL"
