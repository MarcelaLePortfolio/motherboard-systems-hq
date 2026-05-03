#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

OUT="docs/recovery_full_audit/50_observational_task_consumer_trace.txt"

{
echo "PHASE 457 - OBSERVATIONAL TASK CONSUMER TRACE"
echo "============================================="
echo
echo "PURPOSE"
echo "Trace Recent Tasks, Task History, Task Activity wiring sources"
echo

echo "===== PUBLIC TREE ====="
find public -maxdepth 3 -type f | sort
echo

echo "===== DASHBOARD SCRIPT TAGS ====="
grep -n "<script" public/dashboard.html || true
echo

echo "===== BUNDLE ENTRY ====="
if [ -f public/js/dashboard-bundle-entry.js ]; then
sed -n '1,200p' public/js/dashboard-bundle-entry.js
else
echo "MISSING dashboard-bundle-entry.js"
fi
echo

echo "===== TASK SOURCE SEARCH ====="

grep -RIn "recent-tasks" public 2>/dev/null || true
grep -RIn "task-history" public 2>/dev/null || true
grep -RIn "task-activity" public 2>/dev/null || true
grep -RIn "tasks-widget" public 2>/dev/null || true
grep -RIn "mb.task.event" public 2>/dev/null || true
grep -RIn "task-events" public 2>/dev/null || true

echo
echo "===== METRIC SEARCH ====="

grep -RIn "metric-tasks" public 2>/dev/null || true
grep -RIn "metric-success" public 2>/dev/null || true
grep -RIn "metric-latency" public 2>/dev/null || true

echo
echo "===== OBSERVATIONAL TABS ====="

grep -RIn "observational-tabs" public 2>/dev/null || true
grep -RIn "obs-tab-" public 2>/dev/null || true

echo
echo "===== CANDIDATE MODULES ====="

find public/js -type f 2>/dev/null | grep -E "task|history|recent|activity|metric|observ" || true

echo
echo "===== QUICK VERDICT ====="

recent_src=0
history_src=0
activity_src=0

grep -Riq "recent-tasks" public 2>/dev/null && recent_src=1 || true
grep -Riq "task-history" public 2>/dev/null && history_src=1 || true
grep -Riq "task-activity" public 2>/dev/null && activity_src=1 || true

echo "RECENT_TASK_SOURCE=$recent_src"
echo "TASK_HISTORY_SOURCE=$history_src"
echo "TASK_ACTIVITY_SOURCE=$activity_src"

if [ "$recent_src" -eq 0 ]; then
echo "RECENT_TASKS: likely lost consumer wiring"
fi

if [ "$history_src" -eq 0 ]; then
echo "TASK_HISTORY: likely missing consumer module"
fi

if [ "$activity_src" -eq 0 ]; then
echo "TASK_ACTIVITY: likely metric-only fallback"
fi

} > "$OUT"

sed -n '1,300p' "$OUT"
