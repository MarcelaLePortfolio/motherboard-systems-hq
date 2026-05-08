
#!/bin/bash

set -u

OUT="phase716_readonly_audit_output.txt"

: > "$OUT"

{

  printf '%s\n' "===== PHASE 716 SAFE READ-ONLY AUDIT ====="

  printf '\n%s\n' "[1] Confirm branch baseline"

  git branch --show-current

  git status --short

  git log --oneline -3

  printf '\n%s\n' "[2] Confirm containers"

  docker compose ps

  printf '\n%s\n' "[3] Confirm known evidence routes"

  curl -sS -i "http://localhost:3000/api/guidance" | head -20 || true

  curl -sS -i "http://localhost:3000/api/tasks" | head -30 || true

  curl -sS -i "http://localhost:3000/events/task-events" --max-time 3 | head -20 || true

  curl -sS -i -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" --data '{"message":"Runtime verification probe"}' | head -40 || true

  printf '\n%s\n' "[4] Identify safest execution evidence insertion points"

  grep -RniE "Execution Inspector|task-events|run_view|task_events|/events/task-events|/api/runs|/api/tasks" app server 2>/dev/null | head -120 || true

  printf '\n%s\n' "===== PHASE 716 SAFE READ-ONLY AUDIT COMPLETE ====="

} | tee "$OUT"

