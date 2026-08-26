import assert from "node:assert/strict";
import test from "node:test";

import {
  enforceMatildaUserPackageSemanticsFidelity,
  validateMatildaUserPackageSemanticsInput,
  type MatildaPackageSemanticsArtifact,
} from "./ollamaChat";

const authored = (
  expectedOutcome: string | null,
): MatildaPackageSemanticsArtifact => ({
  expectedOutcome,
  proposedWork: "Perform the requested work.",
  proposedArtifacts: null,
  inScope: null,
  outOfScope: null,
  constraints: null,
  unresolvedQuestions: null,
});

test("absent or null typed input preserves behavior", () => {
  assert.equal(
    validateMatildaUserPackageSemanticsInput(undefined),
    null,
  );
  assert.equal(
    validateMatildaUserPackageSemanticsInput(null),
    null,
  );
  assert.doesNotThrow(() =>
    enforceMatildaUserPackageSemanticsFidelity(
      null,
      null,
    ),
  );
});

test("typed input trims explicit values", () => {
  assert.deepEqual(
    validateMatildaUserPackageSemanticsInput({
      expectedOutcome: "  Exact outcome.  ",
    }),
    { expectedOutcome: "Exact outcome." },
  );
});

test("exact matching output passes", () => {
  assert.doesNotThrow(() =>
    enforceMatildaUserPackageSemanticsFidelity(
      { expectedOutcome: "Exact outcome." },
      authored("Exact outcome."),
    ),
  );
});

test("boundary whitespace normalization passes", () => {
  assert.doesNotThrow(() =>
    enforceMatildaUserPackageSemanticsFidelity(
      { expectedOutcome: " Exact outcome. " },
      authored("Exact outcome."),
    ),
  );
});

test("null corresponding output fails closed", () => {
  assert.throws(
    () =>
      enforceMatildaUserPackageSemanticsFidelity(
        { expectedOutcome: "Exact outcome." },
        authored(null),
      ),
    /fidelity for expectedOutcome/,
  );
});

test("semantically similar but non-identical output fails closed", () => {
  assert.throws(
    () =>
      enforceMatildaUserPackageSemanticsFidelity(
        {
          expectedOutcome:
            "One reviewable checklist confirming actual package contents.",
        },
        authored(
          "Create a non-authoritative package interpretation.",
        ),
      ),
    /fidelity for expectedOutcome/,
  );
});

test("omitted typed fields impose no equality requirement", () => {
  assert.doesNotThrow(() =>
    enforceMatildaUserPackageSemanticsFidelity(
      { expectedOutcome: "Exact outcome." },
      {
        ...authored("Exact outcome."),
        proposedWork: "Different interpreted wording.",
      },
    ),
  );
});

test("unknown typed fields fail closed", () => {
  assert.throws(
    () =>
      validateMatildaUserPackageSemanticsInput({
        expectedOutcome: "Exact outcome.",
        unexpectedField: "no",
      }),
    /Unknown explicit user package semantics field/,
  );
});
