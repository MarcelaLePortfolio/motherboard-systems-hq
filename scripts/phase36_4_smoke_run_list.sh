#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:3000}"

echo "=== GET ${BASE_URL}/api/runs?limit=5 ==="
if command -v curl >/dev/null 2>&1; then
  curl -fsS "${BASE_URL}/api/runs?limit=5" | head -c 2000
  echo
  echo "OK: request succeeded (printed first 2000 bytes)."
else
  echo "ERROR: curl not found."
  exit 1
fi
