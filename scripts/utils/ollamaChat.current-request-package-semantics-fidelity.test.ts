import assert from "node:assert/strict";
import test from "node:test";
import fs from "node:fs";

const source = fs.readFileSync(
  new URL("./ollamaChat.ts", import.meta.url),
  "utf8",
);

test("current concrete operation receives deterministic Package Semantics fidelity enforcement", () => {
  assert.match(
    source,
    /enforceConcreteOperationPackageSemanticsFidelity\(\s*context\.concreteOperationMessage,\s*result\.packageSemantics,/,
  );
});

test("current-request fidelity executes before package observer", () => {
  const parse = source.indexOf("const result =");
  const fidelity = source.indexOf(
    "enforceConcreteOperationPackageSemanticsFidelity(",
    parse,
  );
  const observer = source.indexOf(
    "context.observeValidatedPackageSemantics",
    parse,
  );

  assert.ok(fidelity >= 0);
  assert.ok(observer >= 0);
  assert.ok(fidelity < observer);
});

test("fidelity requires preservation of operation and subject", () => {
  const helper = source.indexOf(
    "function enforceConcreteOperationPackageSemanticsFidelity",
  );

  assert.ok(helper >= 0);
  assert.match(source.slice(helper), /preservesOperation/);
  assert.match(source.slice(helper), /preservesSubject/);
  assert.match(
    source.slice(helper),
    /failed current-request Package Semantics fidelity for expectedOutcome/,
  );
});
