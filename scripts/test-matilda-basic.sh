set -e

echo "🧪 Running basic Matilda test..."
RESPONSE=$(curl -s -X POST http://localhost:3001/matilda \
  -H "Content-Type: application/json" \
  -d '{"command":"dev:clean"}')

echo "Raw response: $RESPONSE"

echo "$RESPONSE" | jq . 2>/dev/null || echo "⚠️ Not JSON"
