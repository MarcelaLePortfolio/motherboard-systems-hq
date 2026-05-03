#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs
OUT="docs/phase464_x_server_producer_candidates.txt"

{
  echo "PHASE 464.X — SERVER PRODUCER CANDIDATES"
  echo "========================================"
  echo
  echo "Timestamp (UTC): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo root: $(pwd)"
  echo

  for f in agent.ts dev-server.ts; do
    if [ -f "$f" ]; then
      echo "FILE: $f"
      echo "----------------------------------------"
      rg -n "SYSTEM_HEALTH|operator-guidance|text/event-stream|res.write|setInterval" "$f" || true
      echo
      while IFS=: read -r line _; do
        start=$(( line > 20 ? line - 20 : 1 ))
        end=$(( line + 40 ))
        echo "----- ${f} lines ${start}-${end} -----"
        sed -n "${start},${end}p" "$f"
        echo
      done < <(rg -n "SYSTEM_HEALTH|operator-guidance|text/event-stream|res.write|setInterval" "$f" | cut -d: -f1 | awk '!seen[$0]++')
      echo
    fi
  done
} > "$OUT"

echo "Wrote $OUT"
