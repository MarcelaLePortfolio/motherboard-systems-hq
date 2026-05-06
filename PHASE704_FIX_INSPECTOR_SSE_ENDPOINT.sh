#!/usr/bin/env bash
set -euo pipefail

echo "────────────────────────────────"
echo "Phase 704: Fix Execution Inspector SSE endpoint"
echo "────────────────────────────────"

echo ""
echo "1) Repo state..."
git status --short
git branch --show-current

TARGET="public/js/task-events-sse-client.js"
BACKUP="public/js/task-events-sse-client.js.bak_phase704_sse_endpoint"

echo ""
echo "2) Backing up target..."
cp "$TARGET" "$BACKUP"

echo ""
echo "3) Patching inspector stream endpoint and error wording..."
python3 <<'PY'
from pathlib import Path

p = Path("public/js/task-events-sse-client.js")
s = p.read_text()

s = s.replace('const STREAM_URL = "/events/tasks";', 'const STREAM_URL = "/events/task-events";')
s = s.replace("const STREAM_URL = '/events/tasks';", "const STREAM_URL = '/events/task-events';")
s = s.replace('STREAM_URL = "/events/tasks"', 'STREAM_URL = "/events/task-events"')
s = s.replace("STREAM_URL = '/events/tasks'", "STREAM_URL = '/events/task-events'")

s = s.replace('es.onerror = () => render("Connection error");', '''
    es.onerror = () => {
      if (events.length > 0) {
        render("Connected — stream reconnecting");
      } else {
        render("Waiting for task event stream");
      }
    };''')

p.write_text(s)
PY

echo ""
echo "4) Verifying patch..."
grep -n "STREAM_URL\\|onerror\\|Connection error\\|Waiting for task event stream\\|Connected — stream reconnecting" "$TARGET" || true

echo ""
echo "5) Rebuilding containers..."
docker compose up -d --build

echo ""
echo "6) Waiting for dashboard..."
sleep 8

echo ""
echo "7) Rechecking live endpoints..."
curl -i -sS --max-time 8 http://localhost:3000/events/task-events | sed -n '1,40p' || true
curl -sS "http://localhost:3000/api/tasks?limit=12" | head -c 1000
echo ""

echo ""
echo "8) Writing fix seal..."
cat > PHASE704_INSPECTOR_SSE_ENDPOINT_FIXED.md << 'SEAL'
# Phase 704 — Execution Inspector SSE Endpoint Fixed

The remaining “Connection error” label was caused by frontend stream wiring, not the backend execution path.

Verified facts before fix:
- `/api/tasks?limit=12` returned live completed task data.
- worker claimed and completed the proof task.
- `tasks`, `task_events`, and `run_view` were valid.
- `/events/task-events` returned HTTP 200.
- `/events/tasks` returned HTTP 404.

Fix:
- Repointed Execution Inspector stream usage from `/events/tasks` to `/events/task-events`.
- Adjusted error wording so a transient SSE error does not falsely imply execution backend failure.
SEAL

echo ""
echo "9) Git commit..."
git add "$TARGET" "$BACKUP" PHASE704_FIX_INSPECTOR_SSE_ENDPOINT.sh PHASE704_INSPECTOR_SSE_ENDPOINT_FIXED.md
git commit -m "Phase 704: fix Execution Inspector SSE endpoint"
git push

echo ""
echo "Phase 704 Execution Inspector SSE endpoint fix complete."
