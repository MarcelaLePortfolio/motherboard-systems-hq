
#!/bin/bash

set -u

echo "===== PHASE 716 POST-OVERFLOW RUNTIME VERIFY ====="

echo ""

echo "[1] Branch + latest commits"

git branch --show-current

git status --short

git log --oneline -6

echo ""

echo "[2] Container state"

docker compose ps

echo ""

echo "[3] Dashboard logs tail"

docker compose logs --tail=80 dashboard || true

echo ""

echo "[4] Wait for dashboard HTTP readiness"

for i in 1 2 3 4 5 6 7 8 9 10; do

  code="$(curl -sS -o /tmp/phase716_root_probe.html -w "%{http_code}" http://localhost:3000/ || true)"

  echo "attempt $i root status: $code"

  if [ "$code" = "200" ]; then

    break

  fi

  sleep 2

done

echo ""

echo "[5] Verify served root loads targeted containment CSS"

grep -n "phase716_execution_inspector_containment.css" /tmp/phase716_root_probe.html || true

echo ""

echo "[6] Verify CSS asset"

curl -sS -i "http://localhost:3000/css/phase716_execution_inspector_containment.css" | head -40 || true

echo ""

echo "[7] Verify APIs"

curl -sS -i "http://localhost:3000/api/tasks" | head -40 || true

curl -sS -i "http://localhost:3000/api/guidance" | head -30 || true

echo ""

echo "[8] Final container state"

docker compose ps

echo ""

echo "===== PHASE 716 POST-OVERFLOW RUNTIME VERIFY COMPLETE ====="

