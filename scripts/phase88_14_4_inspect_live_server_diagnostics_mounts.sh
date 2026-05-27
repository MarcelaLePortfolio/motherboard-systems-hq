#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE88_14_4_LIVE_SERVER_DIAGNOSTICS_MOUNTS.txt"

{
  echo "PHASE 88.14.4 LIVE SERVER DIAGNOSTICS MOUNTS"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "Repo: $(pwd)"
  echo "────────────────────────────────"

  echo "SECTION: server.mjs diagnostics references"
  if [[ -f server.mjs ]]; then
    rg -n 'diagnostics|systemHealth|system-health|app\.use|router\.use|express\.Router' server.mjs || true
  else
    echo "server.mjs not found"
  fi

  echo "────────────────────────────────"

  echo "SECTION: diagnostics files present"
  find . -type f | rg -i 'diagnostics|system.*health' | sort || true

  echo "────────────────────────────────"

  echo "SECTION: route directory structure"
  if [[ -d routes ]]; then
    find routes -maxdepth 3 -type f | sort
  else
    echo "routes directory not present"
  fi

  echo "────────────────────────────────"

  echo "SECTION: diagnostics route file previews"
  for file in $(find . -type f | rg -i 'system.*health|diagnostics' | head -20); do
    echo "FILE: $file"
    sed -n '1,80p' "$file" || true
    echo "────────────────────────────────"
  done

  echo "LIKELY ISSUE:"
  echo "Diagnostics route exists but is NOT mounted in server.mjs"
  echo "Next step will be mounting route if confirmed."
} | tee "$OUTPUT_FILE"

