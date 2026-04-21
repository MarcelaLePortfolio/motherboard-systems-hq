#!/bin/bash

set -e

echo "────────────────────────────────"
echo "PHASE 488 — LOCKFILE REPAIR START"
echo "────────────────────────────────"

# 1. Safety check — ensure clean working tree
if [[ -n $(git status --porcelain) ]]; then
  echo "ERROR: Working directory is not clean."
  echo "Please commit or stash changes before proceeding."
  exit 1
fi

echo "✔ Working directory clean"

# 2. Remove existing lockfile and node_modules (build-layer only)
echo "→ Removing lockfile and node_modules..."
rm -f package-lock.json
rm -rf node_modules

# 3. Regenerate lockfile deterministically
echo "→ Regenerating package-lock.json..."
npm install --package-lock-only

# 4. Validate install using npm ci (STRICT check)
echo "→ Validating with npm ci..."
npm ci

echo "✔ npm ci SUCCESS — lockfile synchronized"

# 5. Stage updated lockfile
git add package-lock.json

echo "────────────────────────────────"
echo "LOCKFILE REPAIR COMPLETE"
echo "────────────────────────────────"
echo "Next step: rebuild Docker image to validate cold start"
