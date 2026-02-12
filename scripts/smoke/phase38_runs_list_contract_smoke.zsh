#!/usr/bin/env zsh
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true

BASE_URL="${BASE_URL:-http://127.0.0.1:3000}"
RUNS_URL="${RUNS_URL:-$BASE_URL/api/runs}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "ERROR: missing dependency: $1" >&2; exit 2; }; }
need curl
need jq

tmp_hdr="$(mktemp)"
tmp_body="$(mktemp)"
cleanup() { rm -f "$tmp_hdr" "$tmp_body"; }
trap cleanup EXIT

# Read-only contract smoke: /api/runs must be stable JSON and never write.
http_code="$(
  curl -sS -D "$tmp_hdr" -o "$tmp_body" -w '%{http_code}' \
    -H 'Accept: application/json' \
    "$RUNS_URL"
)"

if [[ "$http_code" != "200" ]]; then
  echo "ERROR: expected 200 from $RUNS_URL, got $http_code" >&2
  echo "=== response headers ===" >&2
  sed -n '1,120p' "$tmp_hdr" >&2 || true
  echo "=== response body (first 2000 chars) ===" >&2
  head -c 2000 "$tmp_body" >&2 || true
  echo >&2
  exit 1
fi

# Content-Type must include json (case-insensitive)
ct="$(awk -F': ' 'BEGIN{IGNORECASE=1} tolower($1)=="content-type"{print tolower($2)}' "$tmp_hdr" | head -n1 | tr -d '\r')"
if [[ -z "$ct" || "$ct" != *"application/json"* ]]; then
  echo "ERROR: expected Content-Type to include application/json; got: ${ct:-<missing>}" >&2
  echo "=== response headers ===" >&2
  sed -n '1,120p' "$tmp_hdr" >&2 || true
  exit 1
fi

# JSON must be an array (possibly empty)
jq -e 'type=="array"' "$tmp_body" >/dev/null

# Contract-stable shape assertions:
# - every element is an object
# - if non-empty, each object must have stable core keys
#   (do not assert ordering; do not assert optional fields)
jq -e '
  (length == 0) or
  (all(.[]; type=="object")
   and all(.[]; has("run_id") and (.run_id|type=="string" and length>0))
   and all(.[]; has("task_id") and (.task_id|type=="string" and length>0))
   and all(.[]; has("status") and (.status|type=="string" and length>0))
  )
' "$tmp_body" >/dev/null

# Ensure no duplicate run_id within the payload (single-owner surface should not duplicate rows)
jq -e '
  (length == 0) or
  ((map(.run_id) | length) == (map(.run_id) | unique | length))
' "$tmp_body" >/dev/null

echo "OK: /api/runs contract stable at $RUNS_URL"
