import assert from "node:assert/strict";
import test from "node:test";
import fs from "node:fs";

const source = fs.readFileSync(
  new URL("./matilda-chat-workflow.ts", import.meta.url),
  "utf8",
);

test("concrete current request becomes Package Semantics fidelity authority", () => {
  assert.match(
    source,
    /concreteOperationMessage:\s*hasConcreteProjectOperation\(message\)\s*\?\s*message\s*:\s*null/,
  );
});

test("retrieval searched state does not establish current-request fidelity authority", () => {
  assert.doesNotMatch(
    source,
    /concreteOperationMessage:\s*projectContextRetrieval\.searched/,
  );
});
