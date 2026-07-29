#!/usr/bin/env bash
set -euo pipefail

cleanup() {
  rm -f .governance-identity-bridge.tsconfig.json
}

trap cleanup EXIT

cat > .governance-identity-bridge.tsconfig.json << 'TSCONFIG'
{
  "extends": "./tsconfig.json",
  "include": [
    "db/governance-runtime.ts",
    "db/mission-read-model-types.ts",
    "db/mission-read-model-assembler.ts",
    "db/mission-read-repository.ts",
    "server/package/production-package-entry-point.ts",
    "server/package/production-package-consumer.ts",
    "server/routes/governance-package-route.ts"
  ]
}
TSCONFIG

printf '\n=== SCOPED TYPE CHECK ===\n'
npx tsc \
  --project .governance-identity-bridge.tsconfig.json \
  --noEmit \
  --pretty false

printf '\n=== PACKAGE PIPELINE TESTS ===\n'
node --test --import tsx \
  server/package/production-package-entry-point.test.ts \
  server/package/production-package-consumer.test.ts \
  server/routes/governance-package-route.test.ts

printf '\n=== MISSION READ TESTS ===\n'
node --test --import tsx \
  db/mission-read-lifecycle-timeline.test.ts \
  db/mission-read-repository.test.ts

printf '\n=== GOVERNANCE PACKAGE SMOKE ===\n'
node scripts/smoke-governance-package-runtime.mjs

printf '\n=== GOVERNANCE PERSISTENCE SMOKE ===\n'
bash scripts/verify-governance-runtime-persistence.sh

printf '\n=== DIFF SAFETY CHECK ===\n'
git diff --check
git diff --stat

printf '\n=== REMOVE TEMPORARY PATCH HELPERS ===\n'
rm -f \
  scripts/apply-governance-identity-bridge.py \
  scripts/fix-governance-package-required-identity-fields.py

printf '\n=== FINAL STATUS ===\n'
git status --short
