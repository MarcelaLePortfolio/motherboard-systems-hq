#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
CANDIDATES="$ROOT/docs/PHASE_487_STEP1_RENDER_BOUNDARY_CANDIDATES.txt"
OUT="$ROOT/docs/PHASE_487_STEP1_PRIORITY_RENDER_CANDIDATE_INSPECTION.txt"
TMP="$ROOT/docs/.phase_487_step1_priority_candidates.tmp"

grep -E '^.*/' "$CANDIDATES" \
  | grep -E '\.(tsx|jsx|ts|js)$' \
  | awk '!seen[$0]++' \
  | head -n 12 > "$TMP"

{
  echo "PHASE 487 — STEP 1 PRIORITY RENDER CANDIDATE INSPECTION"
  echo
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo "Candidate Source: $CANDIDATES"
  echo
  echo "────────────────────────────────"
  echo "INSPECTED FILE COUNT"
  echo "────────────────────────────────"
  wc -l < "$TMP"
  echo

  while IFS= read -r file; do
    if [[ -f "$file" ]]; then
      echo "════════════════════════════════"
      echo "FILE: $file"
      echo "════════════════════════════════"
      echo
      echo "---- EXPORT / COMPONENT LINES ----"
      grep -nE 'export default function|export function|const .*=\s*\(|const .*=\s*function|function ' "$file" || true
      echo
      echo "---- HOOK / LOGIC LINES ----"
      grep -nE 'useState|useEffect|useMemo|useReducer|fetch\(|axios|setInterval|setTimeout|WebSocket|EventSource|socket' "$file" || true
      echo
      echo "---- LABEL / UI TEXT LINES ----"
      grep -nE 'Operator Console|Operator Workspace|Operator Guidance|System Health|SYSTEM_HEALTH|Agent Pool|Active Agents|Tasks Running|Success Rate|Latency|Chat Delegation|Governance|Approval|Execution|Visibility|Trace|Telemetry' "$file" || true
      echo
      echo "---- FIRST 220 LINES ----"
      sed -n '1,220p' "$file"
      echo
    fi
  done < "$TMP"

  echo "────────────────────────────────"
  echo "NEXT ACTION"
  echo "────────────────────────────────"
  echo "Choose the smallest file that:"
  echo "1. renders the current dashboard/operator console,"
  echo "2. already contains the visible section layout,"
  echo "3. can be regrouped by wrappers only,"
  echo "4. does not require hook/data/logic changes."
} > "$OUT"

rm -f "$TMP"

echo "Wrote $OUT"
