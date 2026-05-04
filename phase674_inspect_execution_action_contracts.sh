#!/usr/bin/env bash
set -euo pipefail

echo "=== task mutation / delegate route files ==="
find server app src -type f 2>/dev/null | grep -E "delegate|task|retry|mutation|inspector|execution" | sort | sed -n '1,220p'

echo
echo "=== route definitions involving task actions ==="
grep -R "router\\.post\\|app\\.post\\|/api/delegate-task\\|/api/tasks/create\\|/api/tasks/fail\\|/api/tasks/complete\\|/api/tasks/cancel\\|retry" -n server app src 2>/dev/null | head -260 || true

echo
echo "=== api tasks postgres route ==="
nl -ba server/routes/api-tasks-postgres.mjs | sed -n '1,340p'

echo
echo "=== delegate task references ==="
grep -R "delegate-task" -n . --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=_snapshots 2>/dev/null || true

echo
echo "=== git status ==="
git status --short
