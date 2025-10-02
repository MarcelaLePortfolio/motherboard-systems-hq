set -e

pass() { echo "✅ $1 passed"; }
fail() { echo "❌ $1 failed"; }

echo "<0001f9ea> Running basic Matilda test..."

echo "🧪 Test 1: dev:clean"
RESPONSE=$(curl -s -X POST http://localhost:3001/matilda \
  -H "Content-Type: application/json" \
  -d '{"command":"dev:clean"}')

echo "Raw response (dev:clean): $RESPONSE"
if echo "$RESPONSE" | jq -e '.cadeResult.message | contains("Clean build complete")' >/dev/null; then
  pass "dev:clean"
else
  fail "dev:clean"
fi
echo "🧪 Test 2: chat"
RESPONSE=$(curl -s -X POST http://localhost:3001/matilda \
  -H "Content-Type: application/json" \
  -d '{"command":"chat","payload":{"message":"Hello Matilda"}}')

echo "Raw response (chat): $RESPONSE"
if echo "$RESPONSE" | jq -e '.cadeResult.message | contains("Matilda heard: Hello Matilda")' >/dev/null; then
  pass "chat"
else
  fail "chat"
fi

echo "🎉 All basic Matilda tests finished."
