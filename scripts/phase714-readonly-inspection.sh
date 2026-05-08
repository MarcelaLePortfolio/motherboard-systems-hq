
#!/usr/bin/env bash

set -euo pipefail

echo "────────────────────────────────"

echo "Phase 714 Read-Only Inspection"

echo "────────────────────────────────"

echo ""

echo "Git state:"

git status --short

git log --oneline -5

echo ""

echo "Relevant tracked files:"

git ls-files | grep -Ei '(^|/)(server\.mjs|.*inspector.*|.*task.*|.*guidance.*|.*event.*|.*sse.*)$' | grep -Ev '(^|/)(node_modules|\.next|dist|build|ts-backup)/' | sort || true

echo ""

echo "Potential unsupported certainty wording:"

git grep -InE '\b(healthy|working correctly|operational|stable|recovered|failed because|queue length)\b' -- ':!node_modules' ':!.next' ':!dist' ':!build' ':!ts-backup' || true

echo ""

echo "Task event / run view references:"

git grep -InE 'task_events|run_view|/events/task-events|EventSource|SSE|attempts|max_attempts|claimed_by|run_id' -- ':!node_modules' ':!.next' ':!dist' ':!build' ':!ts-backup' || true

echo ""

echo "Inspection completed successfully."

