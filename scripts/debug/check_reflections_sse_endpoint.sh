#!/usr/bin/env bash
set -euo pipefail

echo "🔎 Checking Reflections SSE candidate endpoints..."

for URL in \
  "http://127.0.0.1:3101/events/reflections" \
  "http://127.0.0.1:3200/events/reflections" \
  "http://127.0.0.1:3201/events/reflections"
do
  echo
  echo ">>> $URL"
  curl -i "$URL" 2>/dev/null | head -n 10 || echo "(curl failed)"
done

echo
echo "✅ Look for the endpoint that returns: Content-Type: text/event-stream"
