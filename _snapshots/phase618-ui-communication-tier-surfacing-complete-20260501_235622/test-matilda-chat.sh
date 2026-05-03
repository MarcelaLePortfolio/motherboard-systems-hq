#!/bin/bash
set -e

echo "🧪 Testing deterministic /api/chat response..."

curl -s -X POST http://127.0.0.1:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"status","agent":"matilda"}'

echo
echo
echo "✅ If the response includes:"
echo '  "ok": true'
echo '  "agent": "matilda"'
echo '  "source": "deterministic-local"'
echo "then the patch is behaving correctly at the route level."
