#!/usr/bin/env bash
set -euo pipefail

echo "────────────────────────────────"
echo "Phase 704: Inspector UI connection-error audit"
echo "────────────────────────────────"

echo ""
echo "1) Repo state..."
git status --short
git branch --show-current

echo ""
echo "2) Container state..."
docker compose ps

echo ""
echo "3) Locate UI connection-error strings..."
grep -RIn \
  "connection error\|Connection error\|disconnected\|Execution Inspector:" \
  public app server 2>/dev/null || true

echo ""
echo "4) Inspect active dashboard script tags around inspector..."
grep -n \
  "execution_inspector\|task-events\|recent_history\|inspector_mount\|bundle.js" \
  public/index.html public/dashboard.html 2>/dev/null || true

echo ""
echo "5) Inspect likely inspector UI scripts..."
for f in \
  public/js/task-events-sse-client.js \
  public/js/phase61_recent_history_wire.js \
  public/js/phase61_inspector_mount.js \
  public/js/dashboard-tasks-widget.js \
  public/index.html
do
  if [ -f "$f" ]; then
    echo ""
    echo "---- $f ----"
    sed -n '1,260p' "$f"
  fi
done

echo ""
echo "6) Probe browser-facing task APIs..."
for url in \
  "http://localhost:3000/" \
  "http://localhost:3000/dashboard" \
  "http://localhost:3000/api/tasks?limit=12" \
  "http://localhost:3000/api/guidance"
do
  echo ""
  echo "---- $url ----"
  curl -i -sS --max-time 8 "$url" | sed -n '1,80p' || true
done

echo ""
echo "7) Probe SSE endpoints with curl max-time..."
for url in \
  "http://localhost:3000/events/task-events" \
  "http://localhost:3000/events/tasks" \
  "http://localhost:3000/events/operator-guidance"
do
  echo ""
  echo "---- $url ----"
  curl -i -N -sS --max-time 5 "$url" | sed -n '1,80p' || true
done

echo ""
echo "8) Recent dashboard logs after SSE probes..."
docker compose logs --tail=120 dashboard || true

echo ""
echo "9) Write audit note..."
cat > PHASE704_INSPECTOR_UI_CONNECTION_ERROR_AUDIT.md << 'SEAL'
# Phase 704 — Inspector UI Connection Error Audit

This audit checks whether the remaining “connection error” label is caused by frontend SSE/status wiring rather than the already-proven execution backend.

Known before this audit:
- Docker runtime is authoritative again.
- `/api/tasks?limit=12` returned the live proof task.
- Worker claimed and completed the proof task.
- `tasks`, `task_events`, and `run_view` all contain the proof path.

This audit inspects:
- frontend strings that emit connection-error/disconnected labels
- dashboard script loading
- inspector JS files
- `/events/task-events`
- `/events/tasks`
- `/events/operator-guidance`
SEAL

git add PHASE704_INSPECTOR_UI_CONNECTION_ERROR_AUDIT.sh PHASE704_INSPECTOR_UI_CONNECTION_ERROR_AUDIT.md
git commit -m "Phase 704: audit inspector UI connection error"
git push

echo ""
echo "Phase 704 inspector UI connection-error audit complete."
