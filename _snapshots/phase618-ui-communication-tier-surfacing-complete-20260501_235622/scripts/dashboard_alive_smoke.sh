#!/usr/bin/env bash
set -euo pipefail

URL="http://127.0.0.1:8080/"

echo "=== dashboard_alive_smoke ==="
echo "URL=$URL"
echo

echo "1) HTTP status check..."
STATUS="$(curl -s -o /dev/null -w "%{http_code}" "$URL" || true)"
echo "HTTP status: $STATUS"

if [[ "$STATUS" != "200" ]]; then
  echo "ERROR: expected 200 from $URL"
  exit 1
fi

echo
echo "2) Content-type check..."
CTYPE="$(curl -sSI "$URL" | awk -F': ' '/^Content-Type:/ {print $2}' | tr -d '\r')"
echo "Content-Type: $CTYPE"

if ! echo "$CTYPE" | grep -qi "text/html"; then
  echo "ERROR: expected text/html"
  exit 1
fi

echo
echo "3) Basic HTML check..."
curl -s "$URL" | head -n 5

echo
echo "OK: dashboard is alive on $URL"
