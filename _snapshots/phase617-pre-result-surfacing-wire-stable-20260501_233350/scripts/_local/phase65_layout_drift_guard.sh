#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 65 — Layout Drift Guard"

BASE_TAG="v63.0-telemetry-integration-golden"

FILES=(
public/dashboard.html
public/css/dashboard.css
public/js/phase61_tabs_workspace.js
public/js/phase61_recent_history_wire.js
)

DRIFT=0

for f in "${FILES[@]}"; do
  if ! git diff --quiet "$BASE_TAG" -- "$f"; then
    echo "DRIFT DETECTED: $f differs from $BASE_TAG"
    DRIFT=1
  else
    echo "OK: $f matches baseline"
  fi
done

if [ "$DRIFT" -eq 1 ]; then
  echo "Layout drift detected. STOP."
  exit 1
fi

echo "Layout drift guard PASS"
