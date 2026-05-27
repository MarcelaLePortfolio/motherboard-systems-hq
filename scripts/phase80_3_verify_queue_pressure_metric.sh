#!/usr/bin/env bash
set -euo pipefail

echo "Phase 80.3 — Queue Pressure Metric Local Verification"

if command -v npx >/dev/null 2>&1; then
  if npx --yes tsx --version >/dev/null 2>&1; then
    npx --yes tsx src/telemetry/computeQueuePressure.test.ts
    echo "Queue Pressure metric verified locally via tsx"
    exit 0
  fi

  if npx --yes ts-node --version >/dev/null 2>&1; then
    npx --yes ts-node src/telemetry/computeQueuePressure.test.ts
    echo "Queue Pressure metric verified locally via ts-node"
    exit 0
  fi
fi

if [ -f dist/telemetry/computeQueuePressure.test.js ]; then
  node dist/telemetry/computeQueuePressure.test.js
  echo "Queue Pressure metric verified locally via compiled dist"
  exit 0
fi

echo "No supported TypeScript runner or compiled dist test found." >&2
echo "Expected one of:" >&2
echo "  - npx tsx" >&2
echo "  - npx ts-node" >&2
echo "  - dist/telemetry/computeQueuePressure.test.js" >&2
exit 1
