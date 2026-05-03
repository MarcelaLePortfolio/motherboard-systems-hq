#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 488 — FINALIZE REPRODUCIBILITY SUCCESS"
echo "────────────────────────────────"

if [[ ! -d .git ]]; then
  echo "ERROR: Run this from the repo root."
  exit 1
fi

if [[ ! -f package-lock.json ]]; then
  echo "ERROR: package-lock.json not found."
  exit 1
fi

echo "→ Current status before staging"
git status --short

echo "→ Staging verified rebuild artifacts"
git add package-lock.json

if [[ -f docs/phase487_cold_start_rebuild_validation.md ]]; then
  git add docs/phase487_cold_start_rebuild_validation.md
fi

if git diff --cached --quiet; then
  echo "ERROR: No staged changes detected."
  exit 1
fi

echo "→ Staged diff summary"
git diff --cached --stat

echo "────────────────────────────────"
echo "PHASE 488 — READY TO COMMIT"
echo "────────────────────────────────"
