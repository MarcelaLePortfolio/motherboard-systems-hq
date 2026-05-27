#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 65 — Protected File Mutation Guard"

PROTECTED_FILES=(
public/dashboard.html
public/css/dashboard.css
public/js/phase61_tabs_workspace.js
public/js/phase61_recent_history_wire.js
)

CHANGED=0

for f in "${PROTECTED_FILES[@]}"; do
  if git diff --name-only | grep -q "^$f$"; then
    echo "PROTECTED FILE MODIFIED: $f"
    CHANGED=1
  fi
done

if [ "$CHANGED" -eq 1 ]; then
  echo ""
  echo "Protected surface modified."
  echo "If intentional:"
  echo "Declare layout phase."
  echo "Create golden checkpoint."
  echo "Run layout contract."
  echo ""
  exit 1
fi

echo "Protected file guard PASS"
