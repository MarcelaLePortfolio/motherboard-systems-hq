#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE88_3_AUTHORITATIVE_SYSTEM_HEALTH_ROUTE.txt"

CANDIDATES=(
  "routes/diagnostics/systemHealth.ts"
  "routes/diagnostics/systemHealth.js"
  "routes/routes/diagnostics/systemHealth.ts"
  "routes/routes/diagnostics/systemHealth.js"
  "routes_backup/diagnostics/systemHealth.ts"
  "routes_backup/diagnostics/systemHealth.js"
)

{
  echo "PHASE 88.3 AUTHORITATIVE SYSTEM HEALTH ROUTE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "Repo: $(pwd)"
  echo "────────────────────────────────"

  for target in "${CANDIDATES[@]}"; do
    echo "FILE: $target"
    if [[ -f "$target" ]]; then
      bytes="$(wc -c < "$target" | tr -d ' ')"
      lines="$(wc -l < "$target" | tr -d ' ')"
      echo "EXISTS: yes"
      echo "BYTES: $bytes"
      echo "LINES: $lines"
      echo "HEAD:"
      sed -n '1,220p' "$target"
    else
      echo "EXISTS: no"
    fi
    echo "────────────────────────────────"
  done
} | tee "$OUTPUT_FILE"
