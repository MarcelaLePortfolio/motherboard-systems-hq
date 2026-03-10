#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

URL="${1:-http://127.0.0.1:8080/dashboard}"
BASE_URL="${URL%/dashboard}"

if ! curl -fsS "$BASE_URL/api/health" >/dev/null 2>&1; then
  echo "Dashboard is not reachable at $BASE_URL"
  echo
  echo "Port 3000 listeners:"
  lsof -iTCP:3000 -sTCP:LISTEN -n -P || true
  echo
  echo "Port 8080 listeners:"
  lsof -iTCP:8080 -sTCP:LISTEN -n -P || true
  echo
  echo "Docker compose status:"
  docker compose ps || true
  exit 7
fi

scripts/verify-dashboard-two-panel.sh "$URL"
