#!/bin/bash
set -u

echo "🔍 Identifying what is serving port 8080..."
echo

echo "1) Listener on 8080"
lsof -nP -iTCP:8080 -sTCP:LISTEN || true
echo
echo "------------------------------------------------"

echo "2) Detailed process info for listener PID(s)"
PIDS="$(lsof -tiTCP:8080 -sTCP:LISTEN | tr '\n' ' ')"
if [ -n "$PIDS" ]; then
  ps -fp $PIDS || true
else
  echo "❌ No listener PID found on 8080"
fi
echo
echo "------------------------------------------------"

echo "3) Docker containers"
docker ps --format 'table {{.ID}}\t{{.Image}}\t{{.Ports}}\t{{.Names}}' 2>/dev/null || echo "docker not available"
echo
echo "------------------------------------------------"

echo "4) Probe HTTP root on 8080"
curl -i --max-time 5 http://127.0.0.1:8080/ || true
echo
echo "------------------------------------------------"

echo "5) Probe /api/chat on 8080"
curl -i --max-time 5 -X POST http://127.0.0.1:8080/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"status","agent":"matilda"}' || true
echo
echo "------------------------------------------------"

echo "6) Search repo for distinctive response markers from live 8080 payload"
grep -RIn --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'deterministic local response active|deterministic-local-response|pipeline":"matilda-stub|Runtime handoff: not enabled in this corridor' . || true
echo
echo "------------------------------------------------"

echo "7) If Docker is involved, inspect matching container metadata"
if command -v docker >/dev/null 2>&1; then
  docker ps --format '{{.ID}} {{.Ports}} {{.Names}}' 2>/dev/null | grep '8080->' | while read -r cid ports name; do
    echo "CONTAINER: $cid $name"
    docker inspect "$cid" --format '{{json .Config.Cmd}} {{json .Config.Entrypoint}} {{json .Mounts}}' || true
    echo "--- last 80 log lines ---"
    docker logs --tail 80 "$cid" 2>&1 || true
    echo "------------------------------------------------"
  done
fi

echo "✅ 8080 inspection complete."
