#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 487 — VERIFY TASK CLARITY FALLBACK LIVE"
echo "────────────────────────────────"

OUT="docs/phase487_verify_task_clarity_fallback_live.md"
mkdir -p docs

{
  echo "# Phase 487 Verify Task Clarity Fallback Live"
  echo
  echo "Generated: $(date)"
  echo
  echo "## Runtime posture"
  echo
  echo '```'
  git status --short
  echo
  docker compose ps
  echo '```'
  echo
  echo "## Served HTML markers"
  echo
  echo '```'
  curl -s http://localhost:8080 | rg -n "phase487-task-clarity-fallback|tasks-widget" || true
  echo '```'
  echo
  echo "## Live task payload"
  echo
  echo '```'
  curl -s http://localhost:8080/api/tasks
  echo
  echo '```'
  echo
  echo "## Browserless task clarity expectation"
  echo
  echo '```'
  python3 - << 'PY'
import json, urllib.request

data = json.loads(urllib.request.urlopen("http://localhost:8080/api/tasks", timeout=5).read().decode())
tasks = data.get("tasks") if isinstance(data, dict) else []
tasks = tasks if isinstance(tasks, list) else []

print("task_count:", len(tasks))
print()

if not tasks:
    print("No recent tasks available.")
else:
    for i, task in enumerate(tasks[:8], 1):
        title = str(task.get("title") or "Untitled task")
        status = str(task.get("status") or "unknown").replace("_", " ")
        updated = task.get("updated_at") or task.get("created_at") or "time unavailable"
        print(f"{i}. {title}")
        print(f"   Status: {status}")
        print(f"   Updated: {updated}")
        print()
PY
  echo '```'
  echo
  echo "## Recent dashboard logs"
  echo
  echo '```'
  docker compose logs --tail=120 dashboard || true
  echo '```'
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
