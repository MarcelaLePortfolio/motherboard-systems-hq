
#!/bin/bash

set -u

OUT="phase716_dashboard_routing_inspection.txt"

: > "$OUT"

{

  echo "===== PHASE 716 DASHBOARD ROUTING INSPECTION ====="

  echo ""

  echo "[1] Branch + status"

  git branch --show-current

  git status --short

  git log --oneline -6

  echo ""

  echo "[2] Package scripts"

  cat package.json || true

  echo ""

  echo "[3] Docker dashboard entrypoint"

  cat Dockerfile.dashboard || true

  echo ""

  echo "[4] Server entry files"

  find . -maxdepth 3 -type f | grep -E 'server\.mjs|server\.js|index\.mjs|index\.js|app\.mjs|app\.js|dashboard' | sort || true

  echo ""

  echo "[5] Main server source"

  sed -n '1,320p' server.mjs || true

  echo ""

  echo "[6] Static/frontend routing clues"

  grep -RniE "express.static|app.use|app.get|next|vite|dist|build|public|dev" server.mjs server app 2>/dev/null | head -220 || true

  echo ""

  echo "[7] Existing reachable HTML routes"

  for path in "/" "/dev" "/dashboard" "/api/tasks" "/api/guidance"; do

    echo ""

    echo "--- $path ---"

    curl -sS -i "http://localhost:3000$path" | head -30 || true

  done

  echo ""

  echo "===== PHASE 716 DASHBOARD ROUTING INSPECTION COMPLETE ====="

} | tee "$OUT"

