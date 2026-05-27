#!/bin/bash
set -e

cd "$(dirname "$0")/.." || exit 1

echo "🔎 Listening process on port 3200 (Reflections):"
lsof -i :3200 -sTCP:LISTEN -P -n || echo "No listener on 3200"

echo ""
echo "🔎 Listening process on port 3201 (OPS):"
lsof -i :3201 -sTCP:LISTEN -P -n || echo "No listener on 3201"

echo ""
echo "🔎 Curl headers for Reflections SSE (http://localhost:3200/events/reflections):"
curl -I http://localhost:3200/events/reflections || echo "curl -I reflections failed"

echo ""
echo "🔎 Curl headers for OPS SSE (http://localhost:3201/events/ops):"
curl -I http://localhost:3201/events/ops || echo "curl -I ops failed"
