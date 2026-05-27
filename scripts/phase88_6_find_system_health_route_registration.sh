#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE88_6_SYSTEM_HEALTH_ROUTE_REGISTRATION.txt"

{
  echo "PHASE 88.6 SYSTEM HEALTH ROUTE REGISTRATION"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "Repo: $(pwd)"
  echo "────────────────────────────────"

  echo "SECTION: IMPORT / REFERENCE HITS"
  if command -v rg >/dev/null 2>&1; then
    rg -n --hidden \
      --glob '!node_modules/**' \
      --glob '!.git/**' \
      --glob '!.next/**' \
      --glob '!dist/**' \
      --glob '!build/**' \
      'systemHealth|diagnostics/systemHealth' .
  else
    grep -RIn \
      --exclude-dir=node_modules \
      --exclude-dir=.git \
      --exclude-dir=.next \
      --exclude-dir=dist \
      --exclude-dir=build \
      -E 'systemHealth|diagnostics/systemHealth' .
  fi
  echo "────────────────────────────────"

  echo "SECTION: EXPRESS ROUTE REGISTRATION HITS"
  if command -v rg >/dev/null 2>&1; then
    rg -n --hidden \
      --glob '!node_modules/**' \
      --glob '!.git/**' \
      --glob '!.next/**' \
      --glob '!dist/**' \
      --glob '!build/**' \
      'app\.use|router\.use|express\.Router|new Router|diagnostics' routes src dashboard .
  else
    grep -RIn \
      --exclude-dir=node_modules \
      --exclude-dir=.git \
      --exclude-dir=.next \
      --exclude-dir=dist \
      --exclude-dir=build \
      -E 'app\.use|router\.use|express\.Router|new Router|diagnostics' \
      routes src dashboard . 2>/dev/null || true
  fi
  echo "────────────────────────────────"

  echo "SECTION: CANDIDATE FILE HEADS"
  for target in \
    routes/diagnostics/systemHealth.ts \
    routes/diagnostics/systemHealth.js \
    routes/routes/diagnostics/systemHealth.ts \
    routes/routes/diagnostics/systemHealth.js
  do
    if [[ -f "$target" ]]; then
      echo "FILE: $target"
      sed -n '1,120p' "$target"
      echo "────────────────────────────────"
    fi
  done
} | tee "$OUTPUT_FILE"
