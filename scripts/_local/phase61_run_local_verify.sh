#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

URL="${1:-http://127.0.0.1:3000/dashboard}"

if ! curl -fsS "$URL" >/dev/null 2>&1; then
  lsof -iTCP:3000 -sTCP:LISTEN -n -P || true
  docker compose ps || true
  exit 7
fi

scripts/verify-dashboard-two-panel.sh "$URL"
