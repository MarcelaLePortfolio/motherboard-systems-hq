#!/usr/bin/env bash
set -euo pipefail

# Simple test for the Matilda /api/chat stub via the dashboard container.

URL="${1:-http://127.0.0.1:8080/api/chat}"

echo "POST $URL"
echo

curl -sS -X POST "$URL" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hi Matilda, this is a stubbed pipeline test from the test script.",
    "agent": "matilda"
  }'

echo
