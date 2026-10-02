import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

import {
  hasConcreteProjectOperation,
} from "./matilda-project-context-retrieval";

test("exact dashboard dogfood is a concrete project operation", () => {
  assert.equal(
    hasConcreteProjectOperation(
      "Remove the Packages tab from the sidebar.",
    ),
    true,
  );
});

test("vague frontend intent does not require concrete-operation semantics", () => {
  assert.equal(
    hasConcreteProjectOperation(
      "I would like to start by making changes to the frontend",
    ),
    false,
  );
});

test("ordinary project question is not classified as a concrete operation", () => {
  assert.equal(
    hasConcreteProjectOperation(
      "How does durable interpretation persistence work?",
    ),
    false,
  );
});

test("repository verification request is not classified as a concrete operation", () => {
  assert.equal(
    hasConcreteProjectOperation(
      "Please verify the repository state before we proceed.",
    ),
    false,
  );
});

test("workflow reuses concrete-operation classifier for Package Semantics requirement", () => {
  const source = fs.readFileSync(
    "server/matilda-chat-workflow.ts",
    "utf8",
  );

  assert.match(
    source,
    /input\.requirePackageSemantics === true\s*\|\|\s*hasConcreteProjectOperation\(message\)/,
  );

  assert.match(
    source,
    /executionAuthorized:\s*false,\s*requirePackageSemantics,/,
  );

  assert.match(
    source,
    /enforceMatildaWorkflowPackageSemanticsRequirement\(\s*requirePackageSemantics,\s*ollamaResult\.packageSemantics,/,
  );

  assert.doesNotMatch(
    source,
    /projectContextRetrieval\.searched\s*(?:===\s*true)?\s*\|\|/,
  );
});
