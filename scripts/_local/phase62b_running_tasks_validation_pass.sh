#!/usr/bin/env bash
set -euo pipefail

OUT="docs/checkpoints/PHASE62B_RUNNING_TASKS_VALIDATION_PASS_20260316.md"
mkdir -p docs/checkpoints

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

has_npm_script() {
  local name="$1"
  node -e '
    const fs = require("fs");
    const name = process.argv[1];
    const p = JSON.parse(fs.readFileSync("package.json", "utf8"));
    const scripts = p.scripts || {};
    process.exit(Object.prototype.hasOwnProperty.call(scripts, name) ? 0 : 1);
  ' "$name"
}

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
    node -e '
      const p = require("./package.json");
      const s = p.scripts || {};
      Object.keys(s).sort().forEach((k) => console.log(k + " = " + s[k]));
    ' | grep -E 'layout|telemetry|drift|replay|test' || true
  else
    echo "package.json not found"
  fi
  echo
  echo "────────────────────────────────"
  echo
  echo "VALIDATION RESULTS"
  echo
  if [ -f package.json ]; then
    if has_npm_script "telemetry:replay-check"; then
      run_cmd "telemetry:replay-check" npm run telemetry:replay-check
    else
      echo "SKIP telemetry:replay-check (script not present)"
      echo
    fi

    if has_npm_script "telemetry:drift-check"; then
      run_cmd "telemetry:drift-check" npm run telemetry:drift-check
    else
      echo "SKIP telemetry:drift-check (script not present)"
      echo
    fi

    if has_npm_script "layout:contract-check"; then
      run_cmd "layout:contract-check" npm run layout:contract-check
    else
      echo "SKIP layout:contract-check (script not present)"
      echo
    fi

    if has_npm_script "test"; then
      run_cmd "test" npm test
    else
      echo "SKIP test (script not present)"
      echo
    fi
  fi
  echo "────────────────────────────────"
  echo
  echo "SUCCESS CONDITION"
  echo "Running Tasks derivation added in bounded telemetry surface."
  echo "Review PASS/FAIL results above before any further change."
} > "$OUT"

printf 'Wrote %s\n' "$OUT"
