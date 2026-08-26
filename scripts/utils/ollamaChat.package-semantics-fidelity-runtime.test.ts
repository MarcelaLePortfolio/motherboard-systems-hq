import assert from "node:assert/strict";
import test from "node:test";

import {
  ollamaChat,
  type MatildaPackageSemanticsArtifact,
} from "./ollamaChat";

const originalFetch = globalThis.fetch;

function responseWith(
  packageSemantics: MatildaPackageSemanticsArtifact | null,
  selectedContextSegments: unknown = [],
): Response {
  return {
    ok: true,
    json: async () => ({
      response: JSON.stringify({
        reply: "Answer.",
        explanationStatus: "optional",
        selectedContextSegments,
        supportSourceReferences: [],
        evidence: null,
        investigationLifecycle: null,
        packageSemantics,
        durableInterpretation:
          "The user requested package semantics validation.",
      }),
    }),
  } as Response;
}

const exactOutcome = "Exact typed expected outcome.";

const matchingArtifact: MatildaPackageSemanticsArtifact = {
  expectedOutcome: exactOutcome,
  proposedWork: null,
  proposedArtifacts: null,
  inScope: null,
  outOfScope: null,
  constraints: null,
  unresolvedQuestions: null,
};

test("exact typed expectedOutcome passes runtime fidelity and observer", async () => {
  let fetchCount = 0;
  let observed: MatildaPackageSemanticsArtifact | null | undefined;

  globalThis.fetch = (async () => {
    fetchCount += 1;
    return responseWith(matchingArtifact);
  }) as typeof globalThis.fetch;

  try {
    const result = await ollamaChat("Question.", {
      userPackageSemantics: {
        expectedOutcome: exactOutcome,
      },
      observeValidatedPackageSemantics: (value) => {
        observed = value;
      },
    });

    assert.equal(fetchCount, 1);
    assert.equal(result.packageSemantics?.expectedOutcome, exactOutcome);
    assert.equal(observed?.expectedOutcome, exactOutcome);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("mismatch fails before package observer and selected-context rejection", async () => {
  let observerCalled = false;
  let fetchCount = 0;

  globalThis.fetch = (async () => {
    fetchCount += 1;
    return responseWith(
      {
        ...matchingArtifact,
        expectedOutcome: "Different authored outcome.",
      },
      [
        {
          relativePath: "not-supplied.ts",
          sourceStartLine: 1,
          sourceEndLine: 1,
        },
      ],
    );
  }) as typeof globalThis.fetch;

  try {
    await assert.rejects(
      () =>
        ollamaChat("Question.", {
          userPackageSemantics: {
            expectedOutcome: exactOutcome,
          },
          observeValidatedPackageSemantics: () => {
            observerCalled = true;
          },
        }),
      /explicit user package semantics fidelity for expectedOutcome/i,
    );

    assert.equal(fetchCount, 1);
    assert.equal(observerCalled, false);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("null packageSemantics fails fidelity before observer", async () => {
  let observerCalled = false;

  globalThis.fetch = (async () =>
    responseWith(null)) as typeof globalThis.fetch;

  try {
    await assert.rejects(
      () =>
        ollamaChat("Question.", {
          userPackageSemantics: {
            expectedOutcome: exactOutcome,
          },
          observeValidatedPackageSemantics: () => {
            observerCalled = true;
          },
        }),
      /explicit user package semantics fidelity: packageSemantics was null/i,
    );

    assert.equal(observerCalled, false);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("absent typed input preserves existing runtime behavior", async () => {
  globalThis.fetch = (async () =>
    responseWith(matchingArtifact)) as typeof globalThis.fetch;

  try {
    const result = await ollamaChat("Question.");
    assert.equal(result.packageSemantics?.expectedOutcome, exactOutcome);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("null typed input preserves existing runtime behavior", async () => {
  globalThis.fetch = (async () =>
    responseWith(matchingArtifact)) as typeof globalThis.fetch;

  try {
    const result = await ollamaChat("Question.", {
      userPackageSemantics: null,
    });
    assert.equal(result.packageSemantics?.expectedOutcome, exactOutcome);
  } finally {
    globalThis.fetch = originalFetch;
  }
});
