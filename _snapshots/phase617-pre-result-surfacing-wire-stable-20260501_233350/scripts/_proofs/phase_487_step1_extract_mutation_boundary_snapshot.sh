#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
TOP="$ROOT/docs/PHASE_487_STEP1_TOP_RENDER_CANDIDATE.txt"
OUT="$ROOT/docs/PHASE_487_STEP1_MUTATION_BOUNDARY_SNAPSHOT.txt"

TARGET_FILE="$(awk -F': ' '/^Selected File: / {print $2; exit}' "$TOP")"

if [[ -z "${TARGET_FILE:-}" ]]; then
  echo "Could not determine selected file from $TOP" >&2
  exit 1
fi

if [[ ! -f "$TARGET_FILE" ]]; then
  echo "Selected file does not exist: $TARGET_FILE" >&2
  exit 1
fi

RETURN_LINES="$(grep -nE 'return \(' "$TARGET_FILE" | cut -d: -f1 | head -n 5 || true)"
LABEL_LINES="$(grep -nE 'Operator Console|Operator Workspace|Operator Guidance|System Health|SYSTEM_HEALTH|Agent Pool|Active Agents|Tasks Running|Success Rate|Latency|Chat Delegation|Governance|Approval|Execution|Visibility|Trace|Telemetry' "$TARGET_FILE" | cut -d: -f1 || true)"

{
  echo "PHASE 487 — STEP 1 MUTATION BOUNDARY SNAPSHOT"
  echo
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Selected File: $TARGET_FILE"
  echo
  echo "────────────────────────────────"
  echo "EXPORT / COMPONENT LINES"
  echo "────────────────────────────────"
  grep -nE 'export default function|export function|const .*=\s*\(|const .*=\s*function|function ' "$TARGET_FILE" || true
  echo
  echo "────────────────────────────────"
  echo "HOOK / LOGIC LINES"
  echo "────────────────────────────────"
  grep -nE 'useState|useEffect|useMemo|useReducer|fetch\(|axios|setInterval|setTimeout|WebSocket|EventSource|socket' "$TARGET_FILE" || true
  echo
  echo "────────────────────────────────"
  echo "LABEL LINES"
  echo "────────────────────────────────"
  grep -nE 'Operator Console|Operator Workspace|Operator Guidance|System Health|SYSTEM_HEALTH|Agent Pool|Active Agents|Tasks Running|Success Rate|Latency|Chat Delegation|Governance|Approval|Execution|Visibility|Trace|Telemetry' "$TARGET_FILE" || true
  echo
  echo "────────────────────────────────"
  echo "RETURN BLOCK SNAPSHOTS"
  echo "────────────────────────────────"
  for line in $RETURN_LINES; do
    start=$(( line > 40 ? line - 40 : 1 ))
    end=$(( line + 180 ))
    echo "---- return() snapshot around line $line ----"
    sed -n "${start},${end}p" "$TARGET_FILE"
    echo
  done
  echo "────────────────────────────────"
  echo "LABEL-ANCHOR SNAPSHOTS"
  echo "────────────────────────────────"
  for line in $LABEL_LINES; do
    start=$(( line > 20 ? line - 20 : 1 ))
    end=$(( line + 40 ))
    echo "---- label snapshot around line $line ----"
    sed -n "${start},${end}p" "$TARGET_FILE"
    echo
  done
  echo "────────────────────────────────"
  echo "NEXT ACTION"
  echo "────────────────────────────────"
  echo "Use this snapshot to identify the narrowest JSX wrapper boundary that can regroup existing sections without changing props, hooks, data flow, or logic."
} > "$OUT"

echo "Wrote $OUT"
