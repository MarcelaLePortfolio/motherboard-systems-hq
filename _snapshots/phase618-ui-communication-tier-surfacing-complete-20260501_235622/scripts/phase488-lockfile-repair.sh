#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 488 — LOCKFILE REPAIR START"
echo "────────────────────────────────"

if ! command -v npm >/dev/null 2>&1; then
  echo "ERROR: npm is not installed or not on PATH."
  exit 1
fi

if [[ ! -f package.json ]]; then
  echo "ERROR: package.json not found. Run this from the repo root."
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "ERROR: Working directory is not clean."
  echo "Dirty files:"
  git status --short
  echo
  echo "Resolve or commit the files above, then re-run this script."
  exit 1
fi

echo "✔ Working directory clean"
echo "→ Removing existing lockfile and node_modules"
rm -f package-lock.json
rm -rf node_modules

echo "→ Regenerating package-lock.json"
npm install --package-lock-only

echo "→ Validating clean install with npm ci"
npm ci

echo "✔ npm ci SUCCESS — lockfile synchronized"
echo "→ Current lockfile diff summary"
git diff -- package-lock.json || true

echo "────────────────────────────────"
echo "PHASE 488 — LOCKFILE REPAIR COMPLETE"
echo "────────────────────────────────"
echo "NEXT:"
echo "1. Review package-lock.json diff"
echo "2. If correct, commit the lockfile"
echo "3. Then run cold-start Docker rebuild validation"
