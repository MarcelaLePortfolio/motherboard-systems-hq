#!/usr/bin/env bash
set -euo pipefail

host="${1:?host required}"
port="${2:?port required}"
timeout_s="${3:-60}"

deadline="$(( $(date +%s) + timeout_s ))"

while true; do
  if nc -z "$host" "$port" >/dev/null 2>&1; then
    exit 0
  fi
  if [ "$(date +%s)" -ge "$deadline" ]; then
    echo "ERROR: tcp not ready: ${host}:${port} (timeout ${timeout_s}s)" >&2
    exit 1
  fi
  sleep 1
done
