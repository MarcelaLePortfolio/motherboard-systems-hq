
#!/usr/bin/env bash

set -euo pipefail

echo "== Phase736 Runtime Validation =="

echo ""

echo "1. Current commit"

git rev-parse HEAD

echo ""

echo "2. Docker status"

docker ps --format "table {{.Names}}\t{{.Status}}"

echo ""

echo "3. Restart dashboard container if present"

if docker ps --format '{{.Names}}' | grep -q '^motherboard-dashboard'; then

  docker restart motherboard-dashboard

  sleep 5

fi

echo ""

echo "4. Restart worker container if present"

if docker ps --format '{{.Names}}' | grep -q '^motherboard-worker'; then

  docker restart motherboard-worker

  sleep 5

fi

echo ""

echo "5. Preview route smoke test"

curl -s http://localhost:3000/api/tasks >/tmp/phase736_tasks_response.json || true

echo ""

echo "6. Dashboard availability"

curl -I http://localhost:3000 || true

echo ""

echo "7. Recent dashboard logs"

if docker ps --format '{{.Names}}' | grep -q '^motherboard-dashboard'; then

  docker logs --tail 120 motherboard-dashboard || true

fi

echo ""

echo "8. Recent worker logs"

if docker ps --format '{{.Names}}' | grep -q '^motherboard-worker'; then

  docker logs --tail 120 motherboard-worker || true

fi

echo ""

echo "9. Runtime validation guidance"

echo "Open dashboard Preview modal and verify:"

echo "- markdown preview still renders"

echo "- visual artifact preview still renders"

echo "- no blank mount"

echo "- no sanitizer errors"

echo "- no decode transport regressions"

echo "- no console exceptions"

echo "- render-native payload path gracefully falls back"

