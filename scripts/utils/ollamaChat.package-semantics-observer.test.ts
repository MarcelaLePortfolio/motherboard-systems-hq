import assert from "node:assert/strict";
import test from "node:test";

import {
  ollamaChat,
  type MatildaPackageSemanticsArtifact,
} from "./ollamaChat";

const originalFetch = globalThis.fetch;

function responseWith(
  packageSemantics: unknown,
  supportSourceReferences: unknown = [],
): Response {
  return {
    ok: true,
    json: async () => ({
      response: JSON.stringify({
        reply: "Answer.",
        explanationStatus: "optional",
        selectedContextSegments: [],
        supportSourceReferences,
        evidence: null,
        investigationLifecycle: null,
        packageSemantics,
        durableInterpretation:
          "The user requested package semantics validation.",
      }),
    }),
  } as Response;
}

test(
  "validation-only observer receives validated package semantics before later support-provenance rejection",
  async () => {
    const observed: Array<
      MatildaPackageSemanticsArtifact | null
    > = [];

    globalThis.fetch = (async () =>
      responseWith(
        {
          expectedOutcome: "A visible checklist.",
          proposedWork: "Create the checklist.",
          proposedArtifacts: "Checklist",
          inScope: "Verify package semantics.",
          outOfScope: null,
          constraints: "Do not change authority.",
          unresolvedQuestions: null,
        },
        [
          {
            type: "conversation_turn",
            sourceTurnId: "not-supplied",
          },
        ],
      )) as typeof globalThis.fetch;

    try {
      await assert.rejects(
        () =>
          ollamaChat("Question.", {
            observeValidatedPackageSemantics:
              (packageSemantics) => {
                observed.push(packageSemantics);
              },
          }),
        /conversation support reference that was not supplied/i,
      );

      assert.equal(observed.length, 1);
      assert.equal(
        observed[0]?.expectedOutcome,
        "A visible checklist.",
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "invalid package semantics fails before validation-only observer",
  async () => {
    let observerCalled = false;

    globalThis.fetch = (async () =>
      responseWith({
        expectedOutcome: "",
        proposedWork: null,
        proposedArtifacts: null,
        inScope: null,
        outOfScope: null,
        constraints: null,
        unresolvedQuestions: null,
      })) as typeof globalThis.fetch;

    try {
      await assert.rejects(
        () =>
          ollamaChat("Question.", {
            observeValidatedPackageSemantics:
              () => {
                observerCalled = true;
              },
          }),
        /empty package semantics field expectedOutcome/i,
      );

      assert.equal(observerCalled, false);
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "normal call without package semantics observer remains unchanged",
  async () => {
    globalThis.fetch = (async () =>
      responseWith(null)) as typeof globalThis.fetch;

    try {
      const result = await ollamaChat("Question.");

      assert.equal(result.reply, "Answer.");
      assert.equal(result.packageSemantics, null);
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
