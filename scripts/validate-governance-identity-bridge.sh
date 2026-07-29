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

run_ts_test() {
  node --import tsx --test "$1"
}

printf '\n=== PACKAGE ENTRY-POINT TEST ===\n'
run_ts_test server/package/production-package-entry-point.test.ts

printf '\n=== PACKAGE CONSUMER TEST ===\n'
run_ts_test server/package/production-package-consumer.test.ts

printf '\n=== GOVERNANCE PACKAGE ROUTE TEST ===\n'
run_ts_test server/routes/governance-package-route.test.ts

printf '\n=== MISSION TIMELINE TEST ===\n'
run_ts_test db/mission-read-lifecycle-timeline.test.ts

printf '\n=== MISSION REPOSITORY TEST ===\n'
run_ts_test db/mission-read-repository.test.ts

printf '\n=== GOVERNANCE PACKAGE SMOKE ===\n'
node --import tsx scripts/smoke-governance-package-runtime.mjs

printf '\n=== GOVERNANCE PERSISTENCE SMOKE ===\n'
bash scripts/verify-governance-runtime-persistence.sh

printf '\n=== DIFF SAFETY CHECK ===\n'
git diff --check

printf '\n=== VALIDATION COMPLETE ===\n'
git status --short
