#!/usr/bin/env bash
set -euo pipefail

echo "Checking available npm scripts..."
npm run || true

echo
echo "Running safe validation (no assumptions)..."

if npm run | grep -q "build"; then
  npm run build
else
  echo "No build script found — skipping build."
fi

if npm run | grep -q "typecheck"; then
  npm run typecheck
else
  echo "No typecheck script found — skipping typecheck."
fi

echo
echo "Final git status:"
git status --short
