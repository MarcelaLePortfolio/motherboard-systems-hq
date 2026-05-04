#!/usr/bin/env bash
set -euo pipefail

echo "=== operator command retry payload ==="
nl -ba server/orchestration/operator-commands.ts | sed -n '1,200p'

echo
echo "=== retry execution router ==="
nl -ba server/retry_execution_router.js | sed -n '1,200p' 2>/dev/null || true

echo
echo "=== delegate taskspec (possible entry point) ==="
nl -ba server/api/tasks-mutations/delegate-taskspec.mjs | sed -n '1,200p' 2>/dev/null || true

echo
echo "=== worker execution policy resolver (retry fields) ==="
nl -ba server/worker/execution_policy_resolver.mjs | sed -n '1,200p' 2>/dev/null || true

echo
echo "=== git status ==="
git status --short
