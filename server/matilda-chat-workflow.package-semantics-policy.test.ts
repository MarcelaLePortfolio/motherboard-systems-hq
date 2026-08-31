import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

import {
  enforceMatildaWorkflowPackageSemanticsRequirement,
} from "./matilda-chat-workflow";

const validSemantics = {
  expectedOutcome: "Preserve the reviewed request-specific outcome.",
  proposedWork: "Revise the reviewed interpretation.",
  proposedArtifacts: null,
  inScope: "The requested revision only.",
  outOfScope: "Canonical approval and downstream execution.",
  constraints: "Remain non-authoritative until separately approved.",
  unresolvedQuestions: null,
};

test("ordinary workflow preserves nullable Package Semantics", () => {
  assert.doesNotThrow(() =>
    enforceMatildaWorkflowPackageSemanticsRequirement(false, null),
  );
});

test("required Package Semantics rejects null", () => {
  assert.throws(
    () => enforceMatildaWorkflowPackageSemanticsRequirement(true, null),
    /requires request-specific Package Semantics with a non-empty expectedOutcome before persistence/,
  );
});

test("required Package Semantics rejects missing expected outcome", () => {
  assert.throws(
    () =>
      enforceMatildaWorkflowPackageSemanticsRequirement(true, {
        ...validSemantics,
        expectedOutcome: null,
      }),
    /requires request-specific Package Semantics with a non-empty expectedOutcome before persistence/,
  );
});

test("required Package Semantics accepts Matilda-authored semantics", () => {
  assert.doesNotThrow(() =>
    enforceMatildaWorkflowPackageSemanticsRequirement(true, validSemantics),
  );
});

test("enforcement occurs before first durable workflow write", () => {
  const source = fs.readFileSync("server/matilda-chat-workflow.ts", "utf8");
  const enforcementIndex = source.indexOf(
    "enforceMatildaWorkflowPackageSemanticsRequirement(",
    source.indexOf("await ollamaChat("),
  );
  const firstWriteIndex = source.indexOf(
    "createInterpretationEvidenceLedgerEntry({",
  );

  assert.ok(enforcementIndex >= 0);
  assert.ok(firstWriteIndex >= 0);
  assert.ok(enforcementIndex < firstWriteIndex);
});

test("Request Changes opts into stronger semantic requirement", () => {
  const source = fs.readFileSync("routes/api-request-changes.ts", "utf8");
  assert.match(source, /requirePackageSemantics:\s*true/);
});
