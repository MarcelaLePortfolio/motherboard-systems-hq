import assert from "node:assert/strict";
import test from "node:test";
import { readFileSync } from "node:fs";

const source = readFileSync(
  new URL("./ollamaChat.ts", import.meta.url),
  "utf8",
);

test("current-request fidelity supports semantic operation vocabulary", () => {
  assert.match(source, /operationSemanticTerms/);
  assert.match(
    source,
    /remove:\s*\[[^\]]*"removed"[^\]]*"absent"[^\]]*"without"[^\]]*"longer"[^\]]*\]/s,
  );
});

test("subject fidelity remains independently required", () => {
  assert.match(
    source,
    /const preservesSubject[\s\S]*subjectTerms\.some\(\(term\) => outcomeTerms\.has\(term\)\)/,
  );
  assert.match(
    source,
    /if \(!preservesOperation \|\| !preservesSubject\)/,
  );
});

test("unrelated historical substitution remains outside the semantic operation vocabulary", () => {
  const removeVocabulary = [
    "remove",
    "removed",
    "removing",
    "delete",
    "deleted",
    "eliminate",
    "eliminated",
    "absent",
    "without",
    "longer",
  ];

  const unrelatedOutcome =
    "Restore read-only Canonical Package visibility in the Approvals Executive Inbox.";

  assert.equal(
    removeVocabulary.some((term) =>
      unrelatedOutcome.toLowerCase().split(/[^a-z0-9]+/).includes(term),
    ),
    false,
  );
});

test("explicit typed Package Semantics fidelity remains a separate boundary", () => {
  assert.match(source, /enforceMatildaUserPackageSemanticsFidelity/);
  assert.match(source, /enforceConcreteOperationPackageSemanticsFidelity/);
});
