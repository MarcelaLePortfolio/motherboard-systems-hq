#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD="feba46c6fec03fd10fca09538d2e62c3d013a2a6"
CURRENT_HEAD="$(git rev-parse HEAD)"
echo "EXPECTED_HEAD=${EXPECTED_HEAD}"
echo "CURRENT_HEAD=${CURRENT_HEAD}"
test "${CURRENT_HEAD}" = "${EXPECTED_HEAD}"

python3 - <<'PY'
from pathlib import Path

path = Path("server/index.ts")
text = path.read_text()

old = '''  const registryPath = pathToFileURL(
    path.resolve(
      process.cwd(),
      "server",
      "project-registry.mjs",
    ),
  ).href;
'''

new = '''  const governanceExecutionCompositionPath = pathToFileURL(
    path.resolve(
      process.cwd(),
      "server",
      "execution",
      "production-governance-execution-composition.mjs",
    ),
  ).href;

  const {
    createProductionGovernanceExecutionRouter,
  } = await import(governanceExecutionCompositionPath);

  app.use(createProductionGovernanceExecutionRouter());

  const registryPath = pathToFileURL(
    path.resolve(
      process.cwd(),
      "server",
      "project-registry.mjs",
    ),
  ).href;
'''

if new not in text:
    if old not in text:
        raise SystemExit("Expected bootstrap insertion anchor not found")
    text = text.replace(old, new, 1)

path.write_text(text)
PY

cat > server/execution/production-governance-execution-mount.test.mjs << 'EOF_TEST'
import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const source = fs.readFileSync("server/index.ts", "utf8");

test("governed production execution composition uses dynamic bootstrap import", () => {
  assert.match(
    source,
    /production-governance-execution-composition\.mjs/,
  );
  assert.match(
    source,
    /await import\(governanceExecutionCompositionPath\)/,
  );
});

test("dedicated governed execution router is mounted exactly once", () => {
  assert.equal(
    (
      source.match(
        /app\.use\(createProductionGovernanceExecutionRouter\(\)\);/g,
      ) ?? []
    ).length,
    1,
  );
});

test("existing route mounts remain intact", () => {
  assert.match(source, /app\.use\(apiChatRouter\);/);
  assert.match(source, /app\.use\(missionReadRouter\);/);
  assert.match(source, /app\.use\(packageReadRouter\);/);
  assert.match(source, /app\.use\(matildaCanonicalPackageRouter\);/);
  assert.match(source, /app\.use\(createGovernanceDelegationRouter\(\)\);/);
});

test("no generic Cade shell mutation scheduler or autonomy route is introduced", () => {
  assert.doesNotMatch(
    source,
    /app\.use\([^;\n]*(?:cade|shell|mutation|scheduler|autonom)[^;\n]*\);/i,
  );
});
EOF_TEST

npx tsx server/execution/production-governance-execution-composition.test.mjs
npx tsx server/execution/production-governance-execution-mount.test.mjs
npx tsx server/routes/governance-execution-route.test.ts
npx tsx server/execution/production-execution-entry-point.test.ts
npx tsx db/governance-execution-read-repository.test.ts
npx tsx db/governance-execution-approval-persistence.test.ts
npx tsx db/governance-execution-scope-persistence.test.ts
npx tsc --noEmit

npx tsx --eval '
import("./server/index.ts")
  .then(() => {
    console.log("SERVER_IMPORT_WITH_DYNAMIC_GOVERNANCE_EXECUTION_MOUNT=PASS");
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
'

echo "DEDICATED_ROUTE_MOUNTED=YES"
echo "PRODUCTION_REACHABILITY=YES"
echo "NEW_AUTHORITY_INTRODUCED=NO"
echo "GENERIC_CADE_REACHABILITY_EXPANDED=NO"
echo "CORRIDOR_6_CLOSURE_NOT_YET_ASSERTED=YES"
