
#!/bin/bash

set -euo pipefail

echo "===== PHASE 717 RETRY CONTRACT DISCOVERY ====="

echo ""

echo "[1] Git checkpoint"

git status --short

git log --oneline --decorate -5

echo ""

echo "[2] Focused retry contract search"

grep -RInE "retry_of_task_id|enforceRetryContract|delegate-task|/api/tasks/create|retry|requeue" \

  app server routes src scripts \

  2>/dev/null | head -200 || true

echo ""

echo "[3] Focused route discovery"

find app server routes src -type f 2>/dev/null | \

grep -E "task|retry|delegate|api" | \

head -120 || true

echo ""

echo "[4] Safe runtime probes"

for route in \

  "/api/tasks" \

  "/api/tasks/create" \

  "/api/delegate-task"

do

  echo ""

  echo "---- $route ----"

  curl -sS -o /tmp/phase717_probe.txt -D - "http://localhost:3000$route" | head -20 || true

done

echo ""

echo "===== COMPLETE ====="

