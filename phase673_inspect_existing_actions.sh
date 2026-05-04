#!/usr/bin/env bash
set -euo pipefail

echo "=== existing delegate/retry/action references ==="
grep -R "delegate-task\|retry\|requeue\|ExecutionInspector\|fetch('/api/tasks\|/api/tasks" -n app server src 2>/dev/null | head -220 || true

echo
echo "=== GuidancePanel current file ==="
nl -ba app/components/GuidancePanel.tsx | sed -n '1,260p'

echo
echo "=== ExecutionInspector current file ==="
nl -ba app/components/ExecutionInspector.tsx | sed -n '1,240p'

echo
echo "=== git status ==="
git status --short
