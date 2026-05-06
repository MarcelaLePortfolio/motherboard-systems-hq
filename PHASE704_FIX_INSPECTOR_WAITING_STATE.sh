#!/usr/bin/env bash
set -euo pipefail

echo "────────────────────────────────"
echo "Phase 704: Fix Execution Inspector waiting state"
echo "────────────────────────────────"

echo ""
echo "1) Repo state..."
git status --short
git branch --show-current

TARGET="public/js/task-events-sse-client.js"
BACKUP="public/js/task-events-sse-client.js.bak_phase704_waiting_state"

echo ""
echo "2) Backing up target..."
cp "$TARGET" "$BACKUP"

echo ""
echo "3) Patching waiting-state behavior..."
python3 <<'PY'
from pathlib import Path

p = Path("public/js/task-events-sse-client.js")
s = p.read_text()

s = s.replace(
'''  function ingest(raw, type) {
    if (type === "hello" || type === "heartbeat") return;''',
'''  function ingest(raw, type) {
    if (type === "hello") {
      render("Connected — watching task stream");
      return;
    }

    if (type === "heartbeat") {
      render("Connected — watching task stream");
      return;
    }'''
)

s = s.replace(
'''    es.onopen = () => render("Connected");''',
'''    es.onopen = () => render("Connected — watching task stream");'''
)

s = s.replace(
'''        render("Waiting for task event stream");''',
'''        render("Connected — awaiting next task event");'''
)

p.write_text(s)
PY

echo ""
echo "4) Verifying patch..."
grep -n "watching task stream\\|awaiting next task event\\|Waiting for task event stream\\|Connection error" "$TARGET" || true

echo ""
echo "5) Rebuilding containers..."
docker compose up -d --build

echo ""
echo "6) Waiting for dashboard..."
sleep 8

echo ""
echo "7) Verifying endpoints..."
curl -i -sS --max-time 5 http://localhost:3000/events/task-events | sed -n '1,40p' || true
curl -sS "http://localhost:3000/api/tasks?limit=12" | head -c 1000
echo ""

echo ""
echo "8) Writing seal..."
cat > PHASE704_INSPECTOR_WAITING_STATE_FIXED.md << 'SEAL'
# Phase 704 — Execution Inspector Waiting State Fixed

The inspector was no longer in backend connection failure. It was showing a waiting label because the frontend ignored `hello` / `heartbeat` stream frames and only rendered connected state after task events.

Fix:
- Treat `hello` as connected stream proof.
- Treat `heartbeat` as connected stream proof.
- Replace misleading waiting/error wording with connected stream status.
- Preserve the live `/api/tasks` path as the authoritative data source for rendered rows.
SEAL

echo ""
echo "9) Git commit..."
git add "$TARGET" "$BACKUP" PHASE704_FIX_INSPECTOR_WAITING_STATE.sh PHASE704_INSPECTOR_WAITING_STATE_FIXED.md
git commit -m "Phase 704: fix Execution Inspector waiting stream state"
git push

echo ""
echo "Phase 704 Execution Inspector waiting-state fix complete."
