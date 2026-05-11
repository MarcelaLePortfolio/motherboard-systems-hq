
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 718 LINEAGE RENDERER INSPECTION ====="

echo ""

echo "[1] Verify repo state"

git status --short

git log --oneline --decorate -5

echo ""

echo "[2] Locate Recent Tasks / lifecycle renderer references"

grep -RIn \

  --exclude-dir=node_modules \

  --exclude-dir=.git \

  --exclude-dir=.next \

  --exclude-dir=dist \

  --exclude-dir=build \

  -E "Recent Tasks|recent tasks|RecentTasks|recentTasks|lifecycle|retry_of_task_id|execution_mode|explanation_preview|operator actions|Retry differently|Requeue|delegate-task" \

  public app src components pages scripts server lib 2>/dev/null || true

echo ""

echo "[3] Locate primary dashboard renderer files"

find public app src components pages -maxdepth 5 -type f 2>/dev/null | grep -Ei '\.(js|jsx|ts|tsx|html|css)$' | sort

echo ""

echo "[4] Inspect task API shape from live runtime if available"

curl -fsS http://localhost:3000/api/tasks | python3 -m json.tool | head -240 || echo "WARN: Could not read http://localhost:3000/api/tasks"

echo ""

echo "[5] Inspect served dashboard for renderer asset references if available"

curl -fsS http://localhost:3000 | head -120 || echo "WARN: Could not read dashboard root"

echo ""

echo "===== INSPECTION COMPLETE ====="

