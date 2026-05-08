
#!/bin/bash

set -u

printf '%s\n' "===== PHASE 716 SAFE READ-ONLY AUDIT ====="

printf '\n%s\n' "[1] Confirm clean branch baseline"

git branch --show-current

git status --short

git log --oneline -3

printf '\n%s\n' "[2] Confirm containers"

docker compose ps

printf '\n%s\n' "[3] Confirm mounted server routes from source"

find app server -type f | sort | grep -E 'api|route|task|event|run_view|inspector|guidance|chat' || true

printf '\n%s\n' "[4] Probe known GET surfaces without jq"

curl -sS -i "http://localhost:3000/api/guidance" | head -40 || true

curl -sS -i "http://localhost:3000/api/tasks" | head -40 || true

curl -sS -i "http://localhost:3000/events/task-events" --max-time 5 | head -40 || true

printf '\n%s\n' "[5] Probe chat POST as one physical line"

curl -sS -i -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" --data '{"message":"Runtime verification probe"}' | head -80 || true

printf '\n%s\n' "[6] Identify evidence surfacing candidates without writing artifacts"

grep -RniE "Execution Inspector|task-events|run_view|task_events|/events/task-events|/api/runs|/api/tasks" app server 2>/dev/null | head -120 || true

printf '\n%s\n' "===== PHASE 716 SAFE READ-ONLY AUDIT COMPLETE ====="

