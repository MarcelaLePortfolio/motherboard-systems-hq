#!/bin/bash
set -e

URL="http://localhost:8080/api/guidance-history"

echo "Testing /api/guidance-history endpoint..."
BODY="$(curl -s -w '\nHTTP_STATUS:%{http_code}' "$URL")"
STATUS="$(echo "$BODY" | sed -n 's/^HTTP_STATUS://p')"
JSON="$(echo "$BODY" | sed '/^HTTP_STATUS:/d')"

if [ -z "$JSON" ]; then
  echo "FAIL: empty response body"
  echo "HTTP status: $STATUS"
  exit 1
fi

echo "$JSON" | jq
echo "HTTP status: $STATUS"

if [ "$STATUS" != "200" ]; then
  echo "FAIL: expected HTTP 200"
  exit 1
fi

echo "PASS: guidance history endpoint returned JSON"
