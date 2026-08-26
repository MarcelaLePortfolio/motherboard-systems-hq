import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

import {
  validateMatildaPackageSemanticsArtifact,
  type MatildaPackageSemanticsArtifact,
} from "./ollamaChat";

const source = fs.readFileSync(
  "scripts/utils/ollamaChat.ts",
  "utf8",
);

function validPackageSemantics(): MatildaPackageSemanticsArtifact {
  return {
    expectedOutcome: "A request-specific approval outcome.",
    proposedWork: "Perform the requested work.",
    proposedArtifacts: "A request-specific artifact.",
    inScope: "Only the requested work.",
    outOfScope: "Unrequested work.",
    constraints: "Preserve the stated boundary.",
    unresolvedQuestions: null,
  };
}

test(
  "Package Semantics is a required nullable structured artifact",
  () => {
    assert.match(source, /"packageSemantics",/);
    assert.match(
      source,
      /packageSemantics:\s*\{\s*anyOf:/s,
    );
    assert.match(
      source,
      /structured response without package semantics/,
    );
  },
);

test(
  "Package Semantics contract contains the complete bounded field set",
  () => {
    for (const field of [
      "expectedOutcome",
      "proposedWork",
      "proposedArtifacts",
      "inScope",
      "outOfScope",
      "constraints",
      "unresolvedQuestions",
    ]) {
      assert.match(source, new RegExp(`"${field}"`));
    }
  },
);

test(
  "Package Semantics validator accepts request-specific typed semantics",
  () => {
    assert.deepEqual(
      validateMatildaPackageSemanticsArtifact(
        validPackageSemantics(),
      ),
      validPackageSemantics(),
    );
  },
);

test(
  "Package Semantics validator trims non-null semantic values",
  () => {
    const artifact = validPackageSemantics();

    assert.equal(
      validateMatildaPackageSemanticsArtifact({
        ...artifact,
        proposedWork: "  Perform the requested work.  ",
      }).proposedWork,
      "Perform the requested work.",
    );
  },
);

test(
  "Package Semantics validator fails closed on empty non-null semantics",
  () => {
    assert.throws(
      () =>
        validateMatildaPackageSemanticsArtifact({
          ...validPackageSemantics(),
          expectedOutcome: "   ",
        }),
      /empty package semantics field expectedOutcome/,
    );
  },
);

test(
  "Package Semantics validator fails closed on malformed field types",
  () => {
    assert.throws(
      () =>
        validateMatildaPackageSemanticsArtifact({
          ...validPackageSemantics(),
          proposedArtifacts: [],
        }),
      /malformed package semantics field proposedArtifacts/,
    );
  },
);

test(
  "Package Semantics prompt requires request-specific semantics and prohibits generic process copy",
  () => {
    assert.match(
      source,
      /Set packageSemantics to null only when the current turn establishes no request-specific structured package semantics\./,
    );

    assert.match(
      source,
      /Do not use generic Living Draft process language as package semantics\./,
    );

    assert.match(
      source,
      /Do not invent scope, deliverables, constraints, outcomes, or unresolved questions\./,
    );
  },
);
