#!/bin/bash
set -e

GUIDANCE_URL="http://localhost:8080/api/guidance"
HISTORY_URL="http://localhost:8080/api/guidance-history"

echo "Triggering guidance endpoint..."
curl -s -f "$GUIDANCE_URL" > /dev/null

echo "Fetching guidance history..."
BODY="$(curl -s -w '\nHTTP_STATUS:%{http_code}' "$HISTORY_URL")"
STATUS="$(echo "$BODY" | sed -n 's/^HTTP_STATUS://p')"
JSON="$(echo "$BODY" | sed '/^HTTP_STATUS:/d')"

if [ -z "$JSON" ]; then
  echo "FAIL: empty response body"
  echo "HTTP status: $STATUS"
  exit 1
fi

echo "$JSON" | jq
echo "HTTP status: $STATUS"

COUNT="$(echo "$JSON" | jq '.history | length')"

if [ "$STATUS" != "200" ] || [ "$COUNT" -lt 1 ]; then
  echo "FAIL: expected HTTP 200 and at least 1 history entry"
  exit 1
fi

echo "PASS: guidance history contains at least 1 entry"
