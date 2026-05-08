
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

echo "Relevant files:"

find . \

  -path "./node_modules" -prune -o \

  -path "./.next" -prune -o \

  -path "./.git" -prune -o \

  -type f \( \

    -name "*Inspector*" -o \

    -name "*Task*" -o \

    -name "*task*" -o \

    -name "*guidance*" -o \

    -name "*event*" -o \

    -name "*sse*" -o \

    -name "server.mjs" \

  \) -print | sort

echo ""

echo "Potential unsupported certainty wording:"

grep -RIn \

  --exclude-dir=node_modules \

  --exclude-dir=.git \

  --exclude-dir=.next \

  --exclude-dir=dist \

  --exclude-dir=build \

  -E '\b(healthy|working correctly|operational|stable|recovered|failed because|queue length)\b' . || true

echo ""

echo "Task event / run view references:"

grep -RIn \

  --exclude-dir=node_modules \

  --exclude-dir=.git \

  --exclude-dir=.next \

  --exclude-dir=dist \

  --exclude-dir=build \

  -E 'task_events|run_view|/events/task-events|EventSource|SSE|attempts|max_attempts|claimed_by|run_id' . || true

echo ""

echo "Read-only inspection complete."

