#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/SERVED_DASHBOARD_SOURCE_TRACE.txt"

{
  echo "SERVED DASHBOARD SOURCE TRACE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo

  echo "=== LOCAL public/dashboard.html MARKERS ==="
  grep -nE 'phase62-top-row|phase61-workspace-grid|Operator Workspace|Telemetry Workspace|Atlas Subsystem Status|Operator Tools|Matilda Chat Console' "$ROOT/public/dashboard.html" || true
  echo

  echo "=== LIVE SERVED OUTPUT MARKERS ==="
  curl -s http://localhost:8080 | grep -nE 'phase62-top-row|phase61-workspace-grid|Operator Workspace|Telemetry Workspace|Atlas Subsystem Status|Operator Tools|Matilda Chat Console' || true
  echo

  echo "=== FILES CONTAINING LIVE-SERVED UNIQUE STRINGS ==="
  grep -RInE 'Operator Tools|Matilda Chat Console|Activity Panels|Subsystem Status|operator-tools-grid' "$ROOT" \
    --include="*.html" --include="*.js" --include="*.ts" --include="*.tsx" \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build || true
  echo

  echo "=== FILES CONTAINING RESTORED SPLIT-LAYOUT UNIQUE STRINGS ==="
  grep -RInE 'phase62-top-row|phase61-workspace-grid|Operator Workspace|Telemetry Workspace' "$ROOT" \
    --include="*.html" --include="*.js" --include="*.ts" --include="*.tsx" \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build || true
  echo

  echo "=== DOCKER / SERVER ENTRYPOINT CANDIDATES ==="
  grep -RInE 'express|sendFile|dashboard.html|public/|static|app.get\\(|app.use\\(' "$ROOT" \
    --include="*.js" --include="*.ts" --include="*.mjs" --include="*.cjs" \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build || true
  echo

  echo "=== SERVER FILES REFERENCING Operator Tools OR Matilda Chat Console ==="
  grep -RIlE 'Operator Tools|Matilda Chat Console|Activity Panels|operator-tools-grid' "$ROOT" \
    --include="*.html" --include="*.js" --include="*.ts" --include="*.tsx" \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build | while read -r f; do
      echo "--- $f ---"
      git log --oneline -- "$f" | head -n 20
      echo
    done || true
} | tee "$OUT"
