import assert from "node:assert/strict";
import test from "node:test";
import { readFile } from "node:fs/promises";

const SOURCE = new URL("./ollamaChat.ts", import.meta.url);

test("concrete operation is presented as authoritative expectedOutcome grounding before generation", async () => {
  const source = await readFile(SOURCE, "utf8");

  assert.match(
    source,
    /Authoritative current concrete operation for Package Semantics expectedOutcome:/,
  );

  assert.match(
    source,
    /context\.concreteOperationMessage/,
  );

  assert.match(
    source,
    /must not replace its operation, direction, or subject/,
  );
});

test("attempt 3 preserves the existing post-generation fidelity guard", async () => {
  const source = await readFile(SOURCE, "utf8");

  assert.match(
    source,
    /function enforceConcreteOperationPackageSemanticsFidelity\(/,
  );

  assert.match(
    source,
    /Ollama response failed current-request Package Semantics fidelity for expectedOutcome\./,
  );
});
