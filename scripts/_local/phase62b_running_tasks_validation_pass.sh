#!/usr/bin/env bash
set -euo pipefail

OUT="docs/checkpoints/PHASE62B_RUNNING_TASKS_VALIDATION_PASS_20260316.md"
mkdir -p docs/checkpoints

{
  echo "PHASE 62B — RUNNING TASKS VALIDATION PASS"
  echo "Date: 2026-03-16"
  echo
  echo "────────────────────────────────"
  echo
  echo "BASELINE"
  echo "Branch: $(git branch --show-current || true)"
  echo "HEAD: $(git rev-parse --short HEAD || true)"
  echo
  echo "git status --short"
  git status --short || true
  echo
  echo "────────────────────────────────"
  echo
  echo "IMPLEMENTATION DIFF"
  git --no-pager diff --stat HEAD~1..HEAD -- public/js/phase22_task_delegation_live_bindings.js || true
  echo
  echo "────────────────────────────────"
  echo
  echo "RUNNING TASKS SURFACE SNAPSHOT"
  rg -n "runningTaskIds|terminalTaskIds|getRunningTasksCount|updateRunningTaskDerivation|updateCountersUI|onTaskEvent" public/js/phase22_task_delegation_live_bindings.js || true
  echo
  echo "────────────────────────────────"
  echo
  echo "PACKAGE VALIDATION COMMANDS"
  if [ -f package.json ]; then
    node -e 'const p=require("./package.json"); const s=p.scripts||{}; Object.keys(s).sort().forEach(k=>console.log(k))' | grep -E 'layout|telemetry|drift|replay|test' || true
  else
    echo "package.json not found"
  fi
  echo
  echo "────────────────────────────────"
  echo
  echo "VALIDATION RESULTS"
  echo
  run_cmd() {
    local label="$1"
    shift
    echo ">>> $label"
    if "$@"; then
      echo "RESULT: PASS"
    else
      echo "RESULT: FAIL"
    fi
    echo
  }
  if [ -f package.json ]; then
    npm run | grep -q "telemetry:replay-check" && run_cmd "telemetry:replay-check" npm run telemetry:replay-check || echo "SKIP telemetry:replay-check (script not present)"
    npm run | grep -q "telemetry:drift-check" && run_cmd "telemetry:drift-check" npm run telemetry:drift-check || echo "SKIP telemetry:drift-check (script not present)"
    npm run | grep -q "layout:contract-check" && run_cmd "layout:contract-check" npm run layout:contract-check || echo "SKIP layout:contract-check (script not present)"
    npm run | grep -qE "^  test$|^test$" && run_cmd "test" npm test -- --runInBand || echo "SKIP test (script not present)"
  fi
  echo
  echo "────────────────────────────────"
  echo
  echo "SUCCESS CONDITION"
  echo "Running Tasks derivation added in bounded telemetry surface."
  echo "Review PASS/FAIL results above before any further change."
} > "$OUT"

printf 'Wrote %s\n' "$OUT"
