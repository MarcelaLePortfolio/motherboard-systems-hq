#!/usr/bin/env bash
set -euo pipefail

OUT="docs/checkpoints/PHASE62B_RUNNING_TASKS_SURFACE_SHORTLIST_20260316.md"
mkdir -p docs/checkpoints

{
  echo "PHASE 62B — RUNNING TASKS SURFACE SHORTLIST"
  echo "Date: 2026-03-16"
  echo
  echo "────────────────────────────────"
  echo
  echo "PURPOSE"
  echo
  echo "Produce a concise shortlist of the highest-confidence implementation surfaces directly from the repo."
  echo
  echo "Discovery only. No runtime change."
  echo
  echo "────────────────────────────────"
  echo
  echo "BASELINE"
  echo
  echo "Branch: $(git branch --show-current || true)"
  echo "HEAD: $(git rev-parse --short HEAD || true)"
  echo
  git status --short || true
  echo
  echo "────────────────────────────────"
  echo
  echo "TOP CANDIDATE FILES"
  echo

  if command -v rg >/dev/null 2>&1; then
    rg -n \
      --glob '!node_modules' \
      --glob '!.next' \
      --glob '!dist' \
      --glob '!coverage' \
      --glob '!.git' \
      'task-events|task\.created|task\.started|task\.running|task\.completed|task\.failed|task\.cancelled|runningTasks|tasksRunning|telemetry|metric|reducer|EventSource|SSE|dashboard' . \
      | awk -F: '{print $1}' \
      | sort \
      | uniq -c \
      | sort -nr \
      | head -25
  else
    grep -RInE \
      'task-events|task\.created|task\.started|task\.running|task\.completed|task\.failed|task\.cancelled|runningTasks|tasksRunning|telemetry|metric|reducer|EventSource|SSE|dashboard' . \
      --exclude-dir=node_modules \
      --exclude-dir=.next \
      --exclude-dir=dist \
      --exclude-dir=coverage \
      --exclude-dir=.git \
      | awk -F: '{print $1}' \
      | sort \
      | uniq -c \
      | sort -nr \
      | head -25
  fi

  echo
  echo "────────────────────────────────"
  echo
  echo "SELECTION RULE"
  echo
  echo "Select ONE file only."
  echo "Prefer existing telemetry reducer surface."
  echo
  echo "SUCCESS CONDITION"
  echo
  echo "Single bounded implementation surface identified."

} > "$OUT"

printf 'Wrote %s\n' "$OUT"
