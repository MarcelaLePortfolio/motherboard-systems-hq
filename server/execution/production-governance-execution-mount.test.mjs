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
