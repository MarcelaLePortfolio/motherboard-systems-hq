#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 488 — COMMIT LOCKFILE + VALIDATE REBUILD"
echo "────────────────────────────────"

if [[ ! -d .git ]]; then
  echo "ERROR: Run this from the repo root."
  exit 1
fi

if [[ ! -f package-lock.json ]]; then
  echo "ERROR: package-lock.json not found."
  exit 1
fi

if [[ ! -x scripts/phase487_cold_start_rebuild_validation.sh ]]; then
  echo "ERROR: scripts/phase487_cold_start_rebuild_validation.sh is missing or not executable."
  exit 1
fi

echo "→ Current status before staging"
git status --short

echo "→ Staging repaired lockfile"
git add package-lock.json

if git diff --cached --quiet -- package-lock.json; then
  echo "ERROR: No staged changes detected for package-lock.json."
  exit 1
fi

echo "→ Status after staging"
git status --short

echo "→ Running cold-start rebuild validation"
./scripts/phase487_cold_start_rebuild_validation.sh

echo "────────────────────────────────"
echo "PHASE 488 — VALIDATION COMPLETE"
echo "────────────────────────────────"
echo "If the rebuild passed, commit the lockfile."
echo "If the rebuild failed, stop and inspect the validation output before any further changes."
