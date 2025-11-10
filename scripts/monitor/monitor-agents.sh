
set -e
echo "<0001fa7a> Monitoring agent heartbeat..."

check_service() {
  local name=$1
  local url=$2
  local retries=3
  local count=0

  while [ $count -lt $retries ]; do
    if curl -s -I "$url" | grep -q "200"; then
      echo "✅ $name responding."
      return 0
    fi
    count=$((count+1))
    echo "⚠️ $name unresponsive (attempt $count/$retries)"
    sleep 2
  done

  echo "🚨 $name failed all checks — initiating self-heal..."
  pm2 restart all
  tsx scripts/sequences/prewarm-all-agents.ts || echo "⚠️ Prewarm sequence failed during self-heal."
}

check_service "Reflections SSE" "http://localhost:3101/events/reflections"
check_service "OPS SSE" "http://localhost:3201/events/ops"
check_service "Matilda" "http://localhost:3000/matilda"
echo "💚 Heartbeat monitor completed."
