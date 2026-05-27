#!/usr/bin/env bash
set -euo pipefail

OUT="docs/checkpoints/PHASE62B_RUNNING_TASKS_CODE_DISCOVERY_20260316.md"

mkdir -p docs/checkpoints

{
  echo "PHASE 62B — RUNNING TASKS CODE DISCOVERY"
  echo "Date: 2026-03-16"
  echo
  echo "────────────────────────────────"
  echo
  echo "PURPOSE"
  echo
  echo "Locate the narrowest safe implementation surface for Running Tasks telemetry hydration."
  echo
  echo "This is a discovery-only artifact."
  echo "No code behavior is changed by this script."
  echo
  echo "────────────────────────────────"
  echo
  echo "BASELINE"
  echo
  echo "git status --short"
  git status --short || true
  echo
  echo "Current branch:"
  git branch --show-current || true
  echo
  echo "HEAD:"
  git rev-parse --short HEAD || true
  echo
  echo "────────────────────────────────"
  echo
  echo "CANDIDATE FILES — task events / telemetry / SSE / reducer / dashboard tiles"
  echo
  if command -v rg >/dev/null 2>&1; then
    rg -n --glob '!node_modules' --glob '!.next' --glob '!dist' --glob '!coverage' \
      'task-events|task\.created|task\.started|task\.running|task\.completed|task\.failed|task\.cancelled|EventSource|SSE|telemetry|metrics|reducer|runningTasks|tasksRunning|dashboard' . || true
  else
    grep -RInE 'task-events|task\.created|task\.started|task\.running|task\.completed|task\.failed|task\.cancelled|EventSource|SSE|telemetry|metrics|reducer|runningTasks|tasksRunning|dashboard' . \
      --exclude-dir=node_modules --exclude-dir=.next --exclude-dir=dist --exclude-dir=coverage || true
  fi
  echo
  echo "────────────────────────────────"
  echo
  echo "LIKELY TELEMETRY SURFACES"
  echo
  find . \
    \( -path './node_modules' -o -path './.next' -o -path './dist' -o -path './coverage' -o -path './.git' \) -prune -o \
    \( -iname '*telemetry*' -o -iname '*metric*' -o -iname '*reducer*' -o -iname '*event*' -o -iname '*dashboard*' -o -iname '*signal*' \) \
    -type f -print | sort || true
  echo
  echo "────────────────────────────────"
  echo
  echo "PACKAGE COMMAND DISCOVERY"
  echo
  if [ -f package.json ]; then
    node -e 'const p=require("./package.json"); const s=p.scripts||{}; Object.keys(s).sort().forEach(k=>console.log(k+" = "+s[k]))' || true
  else
    echo "package.json not found at repo root"
  fi
  echo
  echo "────────────────────────────────"
  echo
  echo "RECOMMENDED NEXT STEP"
  echo
  echo "1. Identify the single file that currently derives dashboard telemetry from task-events."
  echo "2. Add an isolated runningTasks derivation helper only in that surface."
  echo "3. Add bounded tests for duplicate events, terminal-first ordering, and replay stability."
  echo "4. Do not bind UI unless an existing Running Tasks tile is already present."
  echo
  echo "SUCCESS CONDITION"
  echo
  echo "Discovery complete."
  echo "Implementation may begin only after selecting one narrow derivation surface."
} > "$OUT"

printf 'Wrote %s\n' "$OUT"
