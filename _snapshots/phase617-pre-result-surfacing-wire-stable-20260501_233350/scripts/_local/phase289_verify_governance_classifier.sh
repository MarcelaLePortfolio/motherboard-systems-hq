#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

if command -v npx >/dev/null 2>&1; then
  npx tsx src/governance/governance_signal_classifier.test.ts
else
  echo "npx is required to run the Phase 289 governance classifier verification."
  exit 1
fi
