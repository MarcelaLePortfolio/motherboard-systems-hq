#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/PHASE_487_STEP1_UI_SURFACE_INVENTORY.txt"

{
  echo "PHASE 487 — STEP 1 UI SURFACE INVENTORY"
  echo
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo
  echo "────────────────────────────────"
  echo "CANDIDATE DASHBOARD / OPERATOR UI FILES"
  echo "────────────────────────────────"
  find "$ROOT" \
    \( -path "$ROOT/node_modules" -o -path "$ROOT/.git" -o -path "$ROOT/.next" -o -path "$ROOT/dist" -o -path "$ROOT/build" \) -prune -o \
    -type f \
    \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) \
    | grep -Ei '(dashboard|operator|workspace|console|telemetry|approval|governance|execution|trace|agent)' \
    | sort
  echo
  echo "────────────────────────────────"
  echo "MATCHES: UI LABELS / SECTION TEXT"
  echo "────────────────────────────────"
  grep -RInE \
    'Operator Console|Operator Workspace|Operator Guidance|System Health|SYSTEM_HEALTH|Agent Pool|Active Agents|Tasks Running|Success Rate|Latency|Governance|Approval|Execution|Visibility|Trace|Telemetry|Chat Delegation' \
    "$ROOT" \
    --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build \
    | sort || true
  echo
  echo "────────────────────────────────"
  echo "MATCHES: REACT COMPONENT EXPORTS / FUNCTION NAMES"
  echo "────────────────────────────────"
  grep -RInE \
    'export default function|export function|function .*Dashboard|function .*Operator|function .*Workspace|function .*Telemetry|function .*Approval|function .*Governance|function .*Execution|const .*Dashboard|const .*Operator|const .*Workspace' \
    "$ROOT" \
    --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build \
    | sort || true
  echo
  echo "────────────────────────────────"
  echo "MATCHES: STATE / LOGIC HOTSPOTS"
  echo "────────────────────────────────"
  grep -RInE \
    'useState|useEffect|useMemo|useReducer|fetch\(|axios|setInterval|setTimeout|WebSocket|EventSource|SSE|socket|approval|governance|execution|telemetry' \
    "$ROOT" \
    --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build \
    | sort || true
} > "$OUT"

echo "Wrote $OUT"
