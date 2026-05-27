#!/usr/bin/env bash
set -euo pipefail

URL="${1:-http://127.0.0.1:8080/dashboard}"

if command -v open >/dev/null 2>&1; then
  open "$URL"
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$URL"
else
  printf '%s\n' "$URL"
fi
