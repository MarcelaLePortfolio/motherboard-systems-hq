import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const ielSource = fs.readFileSync(
  "db/matilda-interpretation-runtime.ts",
  "utf8",
);

test(
  "IEL write inherits Package Semantics unknown-field rejection from shared validator",
  () => {
    assert.match(
      ielSource,
      /package_semantics_json:\s*[\s\S]*validateMatildaPackageSemanticsArtifact\(\s*input\.package_semantics,\s*"Matilda IEL write contains"/s,
    );
  },
);

test(
  "IEL reconstruction inherits Package Semantics unknown-field rejection from shared validator",
  () => {
    assert.match(
      ielSource,
      /function reconstructPackageSemantics\([\s\S]*validateMatildaPackageSemanticsArtifact\(\s*parsed,\s*"Matilda IEL contains"/s,
    );
  },
);
