#!/usr/bin/env bash
set -euo pipefail

echo "=== key task mutation routes ==="
grep -R "/api/tasks" -n server/routes 2>/dev/null | head -80 || true

echo
echo "=== delegate / retry references ==="
grep -R "delegate-task\|task.retry" -n server src 2>/dev/null | head -80 || true

echo
echo "=== core mutation handlers (focused) ==="
nl -ba server/routes/api-tasks-postgres.mjs | sed -n '1,200p'

echo
echo "=== git status ==="
git status --short
