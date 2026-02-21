#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   scripts/_lib/wait_http.sh "http://127.0.0.1:8080/api/runs" 60
#
# Exits 0 when the URL responds with any HTTP status (including 404).
# Exits non-zero on timeout.

URL="${1:?url required}"
TIMEOUT_S="${2:-60}"

deadline=$(( $(date +%s) + TIMEOUT_S ))

while :; do
  if curl -sS -o /dev/null --connect-timeout 1 --max-time 2 "$URL"; then
    exit 0
  fi

  now="$(date +%s)"
  if (( now >= deadline )); then
    echo "ERROR: timeout waiting for $URL after ${TIMEOUT_S}s" >&2
    exit 1
  fi

  sleep 0.5
done
