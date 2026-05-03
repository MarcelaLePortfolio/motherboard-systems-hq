#!/usr/bin/env bash
set -euo pipefail

echo "== Phase 62B Tasks Queued Discovery =="

echo
echo "-- repo root --"
git rev-parse --show-toplevel

echo
echo "-- branch --"
git branch --show-current

echo
echo "-- candidate telemetry files --"
find . \
  -path './node_modules' -prune -o \
  -path './.next' -prune -o \
  -path './dist' -prune -o \
  -path './build' -prune -o \
  -type f \( \
    -name '*.ts' -o \
    -name '*.tsx' -o \
    -name '*.js' -o \
    -name '*.jsx' -o \
    -name '*.sql' -o \
    -name '*.md' \
  \) -print | \
grep -E 'telemetry|dashboard|metric|status|task|tasks|hydrat|snapshot|diagnostic|operator' || true

echo
echo "-- existing hydrated metrics references --"
grep -RInE \
  "Tasks Running|Tasks Completed|Tasks Failed|runningTasks|completedTasks|failedTasks|tasksRunning|tasksCompleted|tasksFailed" \
  --exclude-dir=node_modules \
  --exclude-dir=.next \
  --exclude-dir=dist \
  --exclude-dir=build \
  . || true

echo
echo "-- queued/pending status references --"
grep -RInE \
  "queued|pending|enqueued|status.*queued|run_state.*pending" \
  --exclude-dir=node_modules \
  --exclude-dir=.next \
  --exclude-dir=dist \
  --exclude-dir=build \
  . || true

echo
echo "-- count query references --"
grep -RInE \
  "COUNT\\(\\*\\)|count\\(|select .*from tasks|from tasks|where status" \
  --exclude-dir=node_modules \
  --exclude-dir=.next \
  --exclude-dir=dist \
  --exclude-dir=build \
  . || true

echo
echo "-- task schema candidates --"
find . \
  -path './node_modules' -prune -o \
  -path './.next' -prune -o \
  -path './dist' -prune -o \
  -path './build' -prune -o \
  -type f \( -name '*.sql' -o -name '*.ts' -o -name '*.js' \) -print | \
while IFS= read -r file; do
  if grep -qE "create table.*tasks|table.*tasks|tasks\s*[:=]|export const tasks|pgTable\\(['\"]tasks|sqliteTable\\(['\"]tasks" "$file"; then
    echo "FILE: $file"
    grep -nE "create table.*tasks|table.*tasks|status|run_state|state|queued|pending|pgTable\\(['\"]tasks|sqliteTable\\(['\"]tasks" "$file" || true
    echo
  fi
done

echo
echo "-- done --"
echo "Next: use output to confirm exact queued-state definition before wiring metric."
