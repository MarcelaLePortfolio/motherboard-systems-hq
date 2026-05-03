#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 488 — LOCKFILE REPAIR RUN"
echo "────────────────────────────────"

if [[ ! -d .git ]]; then
  echo "ERROR: Run this from the repo root."
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "ERROR: Working tree is not clean."
  git status --short
  exit 1
fi

if [[ ! -x scripts/phase488-lockfile-repair.sh ]]; then
  echo "ERROR: scripts/phase488-lockfile-repair.sh is missing or not executable."
  exit 1
fi

echo "✔ Working tree clean"
echo "→ Running lockfile repair"
./scripts/phase488-lockfile-repair.sh

echo
echo "→ Post-run status"
git status --short

echo "────────────────────────────────"
echo "PHASE 488 — LOCKFILE REPAIR RUN COMPLETE"
echo "────────────────────────────────"
