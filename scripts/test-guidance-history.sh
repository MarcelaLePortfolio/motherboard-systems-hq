#!/bin/bash
set -e

BASE_URL="${BASE_URL:-http://localhost:3000}"
URL="$BASE_URL/api/guidance-history"

echo "Testing /api/guidance-history endpoint at $BASE_URL..."
BODY="$(curl -s -w '\nHTTP_STATUS:%{http_code}' "$URL")"
STATUS="$(echo "$BODY" | sed -n 's/^HTTP_STATUS://p')"
JSON="$(echo "$BODY" | sed '/^HTTP_STATUS:/d')"

echo "Raw response:"
echo "$JSON"
echo "HTTP status: $STATUS"

if [ -z "$JSON" ]; then
  echo "FAIL: empty response body"
  exit 1
fi

echo "$JSON" | jq -e . >/dev/null
echo "$JSON" | jq

if [ "$STATUS" != "200" ]; then
  echo "FAIL: expected HTTP 200"
  exit 1
fi

echo "PASS: guidance history endpoint returned valid JSON"
