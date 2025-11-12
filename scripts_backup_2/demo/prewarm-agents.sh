
echo "🧠 Starting Phase 9.2 Pre-Warm Sequence..."
pm2 resurrect 2>/dev/null || echo "⚠️ No PM2 dump found — continuing fresh."

echo "🔄 Restarting agents (Matilda, Cade, Effie)..."
pm2 restart matilda cade effie || echo "⚠️ Restart fallback triggered."

sleep 3
echo "📡 Checking agent runtime health..."
pm2 list
echo "🤖 Testing Matilda → Cade re-delegation..."
curl -s -X POST http://localhost:3001/matilda \
  -H "Content-Type: application/json" \
  -d '{"message":"Matilda, please delegate a system check to Cade."}' | jq

echo "🌍 Pre-warming Atlas endpoint..."
curl -s http://localhost:3201/status | jq || echo "⚠️ Atlas status endpoint not reachable."

echo "✅ Agents pre-warmed. System ready for demo playback."
