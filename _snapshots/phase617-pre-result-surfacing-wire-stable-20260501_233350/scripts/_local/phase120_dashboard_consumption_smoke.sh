#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "Phase120 dashboard consumption smoke test starting..."

if command -v tsx >/dev/null 2>&1; then
  npx tsx src/cognition/transport/cognitionTransport.dashboardConsumption.test.ts
else
  npx ts-node src/cognition/transport/cognitionTransport.dashboardConsumption.test.ts
fi

echo "Phase120 dashboard consumption smoke test passed"
