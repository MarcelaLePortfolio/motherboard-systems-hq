#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 487 — VERIFY MATILDA STATE-AWARE LIVE (BOUNDED)"
echo "────────────────────────────────"

OUT="docs/phase487_verify_matilda_stateful_live_bounded.md"
mkdir -p docs

{
  echo "# Phase 487 Verify Matilda State-Aware Live (Bounded)"
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
  echo "## Live POST /api/chat"
  echo
  echo '```'
  curl -i -s --max-time 8 -X POST http://localhost:8080/api/chat \
    -H 'Content-Type: application/json' \
    --data '{"message":"Status check after cognition upgrade","agent":"matilda"}' \
    | sed -n '1,160p' || true
  echo
  echo '```'
  echo
  echo "## Source surfaces used by state-aware reply"
  echo
  echo '```'
  echo "/diagnostics/system-health"
  curl -s --max-time 5 http://localhost:8080/diagnostics/system-health || true
  echo
  echo
  echo "/api/tasks"
  curl -s --max-time 5 http://localhost:8080/api/tasks || true
  echo
  echo '```'
  echo
  echo "## Expected reply composition"
  echo
  echo '```'
  python3 - << 'PY'
import json, urllib.request

def fetch(url):
    return json.loads(urllib.request.urlopen(url, timeout=5).read().decode())

health = fetch("http://localhost:8080/diagnostics/system-health")
tasks = fetch("http://localhost:8080/api/tasks")

health_summary = "System state unavailable."
if isinstance(health, dict) and isinstance(health.get("situationSummary"), str):
    health_summary = health["situationSummary"].strip()

task_summary = "No recent tasks."
task_list = tasks.get("tasks") if isinstance(tasks, dict) else None
if isinstance(task_list, list) and task_list:
    t = task_list[0]
    title = t.get("title") or "Untitled task"
    status = str(t.get("status") or "unknown").replace("_", " ")
    task_summary = f"Latest task: {title} (status: {status})"

parts = [
    'You said: "Status check after cognition upgrade"',
    health_summary,
    task_summary,
]

print("\\n\\n".join(parts))
PY
  echo '```'
  echo
  echo "## Recent dashboard logs"
  echo
  echo '```'
  docker compose logs --tail=80 dashboard || true
  echo '```'
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
