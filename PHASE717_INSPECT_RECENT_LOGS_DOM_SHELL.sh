
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 717 RECENT LOGS DOM SHELL INSPECTION ====="

echo ""

echo "[1] Checkpoint"

git status --short

git log --oneline --decorate -5

echo ""

echo "[2] Renderer state"

wc -l public/js/phase530_visible_panels_bridge.js

grep -n 'recentLogs\|gridTemplateRows\|recentCard.style.display\|data-phase717-inspect-logs' public/js/phase530_visible_panels_bridge.js

echo ""

echo "[3] HTML/source owners for recentTasks and recentLogs"

grep -R "recentTasks\|recentLogs\|RECENT LOGS\|RECENT TASKS\|recent-tasks-card" -n public *.html app server \

  --exclude-dir=node_modules \

  --exclude-dir=.git \

  --exclude-dir=.next \

  2>/dev/null | head -120

echo ""

echo "[4] Served dashboard references"

curl -sS http://localhost:3000/ | grep -n "recentTasks\|recentLogs\|RECENT LOGS\|RECENT TASKS\|recent-tasks-card" | head -80 || true

echo ""

echo "===== INSPECTION COMPLETE ====="

