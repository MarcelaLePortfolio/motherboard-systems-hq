#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "Phase 383 — Running replay verification proof suite"

if ! command -v pnpm >/dev/null 2>&1; then
  echo "pnpm not found"
  exit 1
fi

pnpm exec tsx src/governance_investigation/verification/run-replay-verification-proof-suite.ts

echo "Replay verification proof suite execution complete"

