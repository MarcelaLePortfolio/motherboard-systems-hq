
set -e

echo "🧪 Running Matilda self-heal test..."
RESPONSE=$(curl -s -X POST http://localhost:3001/matilda \
  -H "Content-Type: application/json" \
  -d '{"command":"dev:clean"}')

echo "Raw response: $RESPONSE"
echo "$RESPONSE" | jq .
