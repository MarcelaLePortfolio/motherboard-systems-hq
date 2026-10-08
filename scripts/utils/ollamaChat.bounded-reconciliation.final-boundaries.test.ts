import assert from "node:assert/strict";
import test from "node:test";
import { ollamaChat } from "./ollamaChat";

const originalFetch = globalThis.fetch;

const request =
  "Remove the Packages tab from the sidebar while preserving underlying package functionality and authority.";

function responseWith(packageSemantics: unknown): Response {
  return {
    ok: true,
    json: async () => ({
      response: JSON.stringify({
        reply: "Acknowledged.",
        explanationStatus: "optional",
        selectedContextCandidatePositions: [],
        supportSourceReferences: [],
        evidence: null,
        investigationLifecycle: null,
        packageSemantics,
        durableInterpretation: "The user requested a sidebar change.",
      }),
    }),
  } as Response;
}

test("reconciled semantics remain non-authoritative", async () => {
  globalThis.fetch = (async () => responseWith(null)) as typeof fetch;

  try {
    const result = await ollamaChat(request, {
      requirePackageSemantics: true,
      concreteOperationMessage: request,
      executionAuthorized: false,
    });

    assert.equal(result.packageSemantics?.proposedWork, null);
    assert.equal(result.packageSemantics?.proposedArtifacts, null);
    assert.equal(result.packageSemantics?.inScope, null);
    assert.equal(result.packageSemantics?.outOfScope, null);
    assert.match(
      result.packageSemantics?.constraints ?? "",
      /preserving underlying package functionality and authority/i,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("malformed non-outcome semantics fail before observer", async () => {
  let observerCalled = false;

  globalThis.fetch = (async () =>
    responseWith({
      expectedOutcome: null,
      successCriteria: null,
      proposedWork: 42,
      proposedArtifacts: null,
      inScope: null,
      outOfScope: null,
      constraints: null,
      unresolvedQuestions: null,
    })) as typeof fetch;

  try {
    await assert.rejects(
      () =>
        ollamaChat(request, {
          requirePackageSemantics: true,
          concreteOperationMessage: request,
          observeValidatedPackageSemantics: () => {
            observerCalled = true;
          },
        }),
    );

    assert.equal(observerCalled, false);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("valid authored non-outcome fields remain unchanged", async () => {
  const authored = {
    expectedOutcome: "Remove the Packages tab from the sidebar.",
    successCriteria: "Package functionality remains available.",
    proposedWork: null,
    proposedArtifacts: null,
    inScope: "Sidebar navigation only.",
    outOfScope: "Underlying package execution.",
    constraints: "Preserve existing authority.",
    unresolvedQuestions: null,
  };

  globalThis.fetch = (async () =>
    responseWith(authored)) as typeof fetch;

  try {
    const result = await ollamaChat(request, {
      requirePackageSemantics: true,
      concreteOperationMessage: request,
    });

    assert.deepEqual(result.packageSemantics, authored);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("explicitly contradictory non-outcome fields fail before observer", async () => {
  const base = {
    expectedOutcome:
      "Remove the Packages tab from the sidebar while preserving underlying package functionality and authority.",
    successCriteria: null,
    proposedWork: null,
    proposedArtifacts: null,
    inScope: null,
    outOfScope: null,
    constraints: null,
    unresolvedQuestions: null,
  };

  const contradictions = [
    {
      successCriteria: "Underlying package functionality is deleted.",
    },
    {
      proposedWork:
        "Delete package execution services and remove package authority checks.",
    },
    {
      inScope: "Removal of the underlying package execution system.",
    },
    {
      outOfScope: "Preservation of underlying package functionality.",
    },
    {
      constraints:
        "Disable package approval and execution authorization requirements.",
    },
  ];

  for (const contradiction of contradictions) {
    let observerCalled = false;
    globalThis.fetch = (async () =>
      responseWith({ ...base, ...contradiction })) as typeof fetch;

    try {
      await assert.rejects(
        () =>
          ollamaChat(request, {
            requirePackageSemantics: true,
            concreteOperationMessage: request,
            executionAuthorized: false,
            observeValidatedPackageSemantics: () => {
              observerCalled = true;
            },
          }),
        /Package Semantics fidelity/,
      );
      assert.equal(observerCalled, false);
    } finally {
      globalThis.fetch = originalFetch;
    }
  }
});

test("explicit preservation and non-destructive scope remain valid", async () => {
  const authored = {
    expectedOutcome:
      "Remove the Packages tab from the sidebar while preserving underlying package functionality and authority.",
    successCriteria: "Package functionality remains available.",
    proposedWork: "Remove only the sidebar navigation entry.",
    proposedArtifacts: null,
    inScope: "Sidebar navigation only.",
    outOfScope: "Changes to underlying package execution.",
    constraints:
      "Do not delete package execution services or disable package authorization.",
    unresolvedQuestions: null,
  };

  globalThis.fetch = (async () =>
    responseWith(authored)) as typeof fetch;

  try {
    const result = await ollamaChat(request, {
      requirePackageSemantics: true,
      concreteOperationMessage: request,
      executionAuthorized: false,
    });

    assert.deepEqual(result.packageSemantics, authored);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("null semantics without required context remain null", async () => {
  globalThis.fetch = (async () => responseWith(null)) as typeof fetch;

  try {
    const result = await ollamaChat("What is the current status?");
    assert.equal(result.packageSemantics, null);
  } finally {
    globalThis.fetch = originalFetch;
  }
});
