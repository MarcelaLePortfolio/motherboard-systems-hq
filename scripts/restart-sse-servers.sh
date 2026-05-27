#!/bin/bash
set -e

cd "$(dirname "$0")/.." || exit 1

PIDS="$(lsof -ti :3200 -sTCP:LISTEN 2>/dev/null; lsof -ti :3201 -sTCP:LISTEN 2>/dev/null)"

if [ -n "$PIDS" ]; then
  echo "Killing existing SSE processes on ports 3200/3201: $PIDS"
  kill -9 $PIDS || true
else
  echo "No existing SSE listeners found on ports 3200 or 3201."
fi

bash scripts/run-sse-servers.sh
