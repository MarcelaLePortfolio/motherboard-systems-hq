
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 718 RENDERER TARGET DISCOVERY ====="

echo ""

echo "[1] Locate retry/lifecycle renderer references"

grep -RInE "retry_of_task_id|execution_mode|explanation_preview|delegate-task|Retry differently|Requeue|lifecycle badge|operator actions|Recent Tasks|task-events" \

  public app src components pages scripts server lib \

  --exclude-dir=node_modules \

  --exclude-dir=.git \

  --exclude-dir=.next \

  --exclude-dir=dist \

  --exclude-dir=build 2>/dev/null || true

echo ""

echo "[2] Locate likely lifecycle renderer files"

find public app src components pages \

  \( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" \) \

  2>/dev/null | sort | grep -Ei "task|recent|lifecycle|dashboard|retry|execution|history" || true

echo ""

echo "[3] Sample live task payload"

curl -fsS http://localhost:3000/api/tasks | python3 -m json.tool | head -200 || true

echo ""

echo "===== TARGET DISCOVERY COMPLETE ====="

