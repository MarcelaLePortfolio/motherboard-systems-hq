#!/bin/bash
set -e

cd "$(dirname "$0")/.." || exit 1

echo "🔎 Curl headers for Reflections SSE (http://localhost:3200/events/reflections):"
curl -I http://localhost:3200/events/reflections 2>/dev/null | sed -n '1,20p'

echo ""
echo "🔎 Curl headers for OPS SSE (http://localhost:3201/events/ops):"
curl -I http://localhost:3201/events/ops 2>/dev/null | sed -n '1,20p'
