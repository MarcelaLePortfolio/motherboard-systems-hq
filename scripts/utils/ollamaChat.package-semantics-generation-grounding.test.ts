import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";

const sourcePath = path.resolve("scripts/utils/ollamaChat.ts");

test("required Package Semantics prompt preserves concrete operation direction", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(
    source,
    /For a concrete operation, expectedOutcome must preserve the operation and direction established by the current user request\./,
  );

  assert.match(
    source,
    /Do not invert removal or hiding into restoration or showing/,
  );

  assert.match(
    source,
    /do not invert addition or showing into removal or hiding/,
  );
});

test("required Package Semantics prompt keeps preservation requirements as constraints", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(
    source,
    /Treat preservation requirements as constraints on the requested operation, not as substitutes for or reversals of expectedOutcome\./,
  );

  assert.match(
    source,
    /removing a UI tab while preserving its underlying runtime functionality means the expected outcome is removal of the UI tab with that runtime functionality preserved/,
  );

  assert.match(
    source,
    /not restoration of the tab or package visibility/,
  );
});
