#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs
OUT="docs/phase464_x_bundle_source_candidates.txt"

CANDIDATES=(
  "public/js/dashboard-status.js"
  "public/js/operatorGuidance.sse.js"
  "public/js/phase457_restore_task_panels.js"
  "public/js/phase457_neutralize_legacy_observational_consumers.js"
  "dashboard-delegation.js"
  "task-events-sse-client.js"
  "matilda-chat-console.js"
  "phase22_task_delegation_live_bindings.js"
  "phase61_recent_history_wire.js"
)

{
  echo "PHASE 464.X — BUNDLE SOURCE CANDIDATES"
  echo "======================================"
  echo
  echo "Timestamp (UTC): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo root: $(pwd)"
  echo

  echo "ELIMINATION"
  echo "- agent.ts is a heartbeat stub, not guidance producer"
  echo "- dev-server.ts is static file server + /agent-status.json only"
  echo "- next surface = browser bundle-adjacent source files"
  echo

  for f in "${CANDIDATES[@]}"; do
    if [ -f "$f" ]; then
      echo "FILE: $f"
      echo "----------------------------------------"
      rg -n 'SYSTEM_HEALTH|system health|operator-guidance|guidance|atlas-status|Atlas|textContent|innerHTML|appendChild|append\(|insertAdjacent|replaceChildren|EventSource|setInterval|MutationObserver|diagnostics/system-health|Awaiting bounded guidance stream|No active tasks|Awaiting operator input' "$f" || true
      echo
      while IFS=: read -r line _; do
        start=$(( line > 20 ? line - 20 : 1 ))
        end=$(( line + 40 ))
        echo "----- ${f} lines ${start}-${end} -----"
        sed -n "${start},${end}p" "$f"
        echo
      done < <(rg -n 'SYSTEM_HEALTH|system health|operator-guidance|guidance|atlas-status|Atlas|textContent|innerHTML|appendChild|append\(|insertAdjacent|replaceChildren|EventSource|setInterval|MutationObserver|diagnostics/system-health|Awaiting bounded guidance stream|No active tasks|Awaiting operator input' "$f" | cut -d: -f1 | awk '!seen[$0]++' | head -n 20)
      echo
    fi
  done
} > "$OUT"

echo "Wrote $OUT"
