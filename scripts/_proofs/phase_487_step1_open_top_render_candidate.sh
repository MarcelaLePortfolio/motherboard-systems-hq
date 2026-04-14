#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
DECISION="$ROOT/docs/PHASE_487_STEP1_RENDER_BOUNDARY_DECISION.txt"
OUT="$ROOT/docs/PHASE_487_STEP1_TOP_RENDER_CANDIDATE.txt"

TOP_FILE="$(awk '
/^TOP CANDIDATES$/ { in_top=1; next }
/^────────────────────────────────$/ { next }
in_top && /^[1-5]\. / {
  sub(/^[1-5]\. /, "", $0)
  print
  exit
}
' "$DECISION")"

if [[ -z "${TOP_FILE:-}" ]]; then
  echo "No top candidate found in $DECISION" >&2
  exit 1
fi

if [[ ! -f "$TOP_FILE" ]]; then
  echo "Top candidate file does not exist: $TOP_FILE" >&2
  exit 1
fi

{
  echo "PHASE 487 — STEP 1 TOP RENDER CANDIDATE"
  echo
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Decision Source: $DECISION"
  echo "Selected File: $TOP_FILE"
  echo
  echo "────────────────────────────────"
  echo "EXPORT / COMPONENT LINES"
  echo "────────────────────────────────"
  grep -nE 'export default function|export function|const .*=\s*\(|const .*=\s*function|function ' "$TOP_FILE" || true
  echo
  echo "────────────────────────────────"
  echo "HOOK / LOGIC LINES"
  echo "────────────────────────────────"
  grep -nE 'useState|useEffect|useMemo|useReducer|fetch\(|axios|setInterval|setTimeout|WebSocket|EventSource|socket' "$TOP_FILE" || true
  echo
  echo "────────────────────────────────"
  echo "VISIBLE DASHBOARD LABEL LINES"
  echo "────────────────────────────────"
  grep -nE 'Operator Console|Operator Workspace|Operator Guidance|System Health|SYSTEM_HEALTH|Agent Pool|Active Agents|Tasks Running|Success Rate|Latency|Chat Delegation|Governance|Approval|Execution|Visibility|Trace|Telemetry' "$TOP_FILE" || true
  echo
  echo "────────────────────────────────"
  echo "FIRST 320 LINES"
  echo "────────────────────────────────"
  sed -n '1,320p' "$TOP_FILE"
} > "$OUT"

echo "Wrote $OUT"
