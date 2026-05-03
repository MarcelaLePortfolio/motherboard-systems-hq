#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 488 — WORKSPACE CLASSIFICATION APPLY"
echo "────────────────────────────────"

if [[ ! -d .git ]]; then
  echo "ERROR: Run this from the repo root."
  exit 1
fi

DOC_PATH="docs/phase487_diagnostics_surface_live_probe_output.txt"
SCRIPT_A="scripts/phase487_cold_start_rebuild_validation.sh"
SCRIPT_B="scripts/phase487_docker_desktop_controlled_restart.sh"

echo "→ Reverting tracked diagnostics doc"
git restore -- "$DOC_PATH"

echo "→ Ensuring .runtime/ is ignored"
touch .gitignore
if ! grep -qxF '.runtime/' .gitignore; then
  printf '\n.runtime/\n' >> .gitignore
fi

echo "→ Verifying required phase487 scripts exist"
[[ -f "$SCRIPT_A" ]]
[[ -f "$SCRIPT_B" ]]

echo "→ Staging classification set"
git add .gitignore "$SCRIPT_A" "$SCRIPT_B"

echo "→ Current status"
git status --short

echo "────────────────────────────────"
echo "PHASE 488 — WORKSPACE CLASSIFICATION READY"
echo "────────────────────────────────"
