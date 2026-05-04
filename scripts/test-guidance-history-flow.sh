#!/bin/bash
set -e

BASE_URL="${BASE_URL:-http://localhost:3000}"
GUIDANCE_URL="$BASE_URL/api/guidance"
HISTORY_URL="$BASE_URL/api/guidance-history"

echo "Triggering guidance endpoint at $BASE_URL..."
GUIDANCE_BODY="$(curl -s -w '\nHTTP_STATUS:%{http_code}' "$GUIDANCE_URL")"
GUIDANCE_STATUS="$(echo "$GUIDANCE_BODY" | sed -n 's/^HTTP_STATUS://p')"
GUIDANCE_JSON="$(echo "$GUIDANCE_BODY" | sed '/^HTTP_STATUS:/d')"

echo "Guidance raw response:"
echo "$GUIDANCE_JSON"
echo "Guidance HTTP status: $GUIDANCE_STATUS"

echo "$GUIDANCE_JSON" | jq -e . >/dev/null

echo "Fetching guidance history..."
BODY="$(curl -s -w '\nHTTP_STATUS:%{http_code}' "$HISTORY_URL")"
STATUS="$(echo "$BODY" | sed -n 's/^HTTP_STATUS://p')"
JSON="$(echo "$BODY" | sed '/^HTTP_STATUS:/d')"

echo "History raw response:"
echo "$JSON"
echo "History HTTP status: $STATUS"

if [ -z "$JSON" ]; then
  echo "FAIL: empty response body"
  exit 1
fi

echo "$JSON" | jq -e . >/dev/null
echo "$JSON" | jq

COUNT="$(echo "$JSON" | jq '.history | length')"

if [ "$STATUS" != "200" ] || [ "$COUNT" -lt 1 ]; then
  echo "FAIL: expected HTTP 200 and at least 1 history entry"
  exit 1
fi

echo "PASS: guidance history contains at least 1 entry"
