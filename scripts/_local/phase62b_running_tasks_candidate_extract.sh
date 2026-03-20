#!/usr/bin/env bash
set -euo pipefail

SRC="docs/checkpoints/PHASE62B_RUNNING_TASKS_CODE_DISCOVERY_20260316.md"
OUT="docs/checkpoints/PHASE62B_RUNNING_TASKS_CANDIDATE_SURFACES_20260316.md"

mkdir -p docs/checkpoints

{
  echo "PHASE 62B — RUNNING TASKS CANDIDATE SURFACES"
  echo "Date: 2026-03-16"
  echo
  echo "────────────────────────────────"
  echo
  echo "PURPOSE"
  echo
  echo "Reduce the broad discovery report into a narrow shortlist of likely implementation surfaces."
  echo
  echo "This is a triage-only artifact."
  echo "No runtime behavior is changed."
  echo
  echo "────────────────────────────────"
  echo
  echo "SELECTION RULE"
  echo
  echo "Keep only lines likely to identify:"
  echo "• task-events ingestion"
  echo "• telemetry derivation"
  echo "• reducer/state logic"
  echo "• dashboard metric binding"
  echo
  echo "Exclude obvious noise where possible."
  echo
  echo "────────────────────────────────"
  echo
  echo "SHORTLIST"
  echo
  if [ -f "$SRC" ]; then
    grep -Ei 'task-events|task\.created|task\.started|task\.running|task\.completed|task\.failed|task\.cancelled|runningTasks|tasksRunning|telemetry|metric|reducer|dashboard|EventSource|SSE' "$SRC" \
      | grep -E '\.(ts|tsx|js|jsx|mjs|cjs|json|md):[0-9]+|^\./|^[A-Za-z0-9_./-]+\.(ts|tsx|js|jsx|mjs|cjs|json|md)$' \
      | grep -vE 'node_modules|\.next|coverage|dist|docs/checkpoints/PHASE62B_RUNNING_TASKS_CODE_DISCOVERY_20260316\.md' \
      | sort -u || true
  else
    echo "Source discovery report not found: $SRC"
    exit 1
  fi
  echo
  echo "────────────────────────────────"
  echo
  echo "TOP FILE COUNTS"
  echo
  if [ -f "$SRC" ]; then
    grep -Ei 'task-events|task\.created|task\.started|task\.running|task\.completed|task\.failed|task\.cancelled|runningTasks|tasksRunning|telemetry|metric|reducer|dashboard|EventSource|SSE' "$SRC" \
      | grep -Eo '([A-Za-z0-9_./-]+\.(ts|tsx|js|jsx|mjs|cjs|json|md))(:[0-9]+)?' \
      | sed 's/:[0-9]\+$//' \
      | grep -vE 'node_modules|\.next|coverage|dist' \
      | sort \
      | uniq -c \
      | sort -nr || true
  fi
  echo
  echo "────────────────────────────────"
  echo
  echo "RECOMMENDED NEXT STEP"
  echo
  echo "Choose the single highest-confidence telemetry derivation file from the shortlist."
  echo "Do not implement in more than one derivation surface."
  echo
  echo "SUCCESS CONDITION"
  echo
  echo "A narrow candidate list exists for the next bounded code change."
} > "$OUT"

printf 'Wrote %s\n' "$OUT"
