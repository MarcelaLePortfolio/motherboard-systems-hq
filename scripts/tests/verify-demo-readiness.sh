
set -e
echo "🔍 Verifying demo readiness..."
pm2 list
curl -I http://localhost:3101/events/reflections | grep "200" && echo "✅ Reflections SSE OK"
curl -I http://localhost:3201/events/ops | grep "200" && echo "✅ OPS SSE OK"
sqlite3 db/main.db "SELECT COUNT(*) FROM reflection_index;" && echo "✅ SQLite accessible"
echo "🎬 Demo environment verified as ready."
