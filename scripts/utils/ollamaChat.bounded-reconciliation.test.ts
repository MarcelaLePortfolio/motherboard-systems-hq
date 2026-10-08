import assert from "node:assert/strict";
import test from "node:test";
import { ollamaChat } from "./ollamaChat";

const originalFetch = globalThis.fetch;

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

test("reconciles null semantics for a bounded concrete request", async () => {
  globalThis.fetch = (async () => responseWith(null)) as typeof fetch;

  try {
    const result = await ollamaChat(
      "Remove the Packages tab from the sidebar while preserving underlying package functionality and authority.",
      {
        requirePackageSemantics: true,
        concreteOperationMessage:
          "Remove the Packages tab from the sidebar while preserving underlying package functionality and authority.",
      },
    );

    assert.match(
      result.packageSemantics?.expectedOutcome ?? "",
      /remove the Packages tab from the sidebar/i,
    );
    assert.match(
      result.packageSemantics?.constraints ?? "",
      /preserving underlying package functionality and authority/i,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("does not replace contradictory model-authored outcome", async () => {
  globalThis.fetch = (async () =>
    responseWith({
      expectedOutcome: "Add a dashboard widget.",
      successCriteria: null,
      proposedWork: null,
      proposedArtifacts: null,
      inScope: null,
      outOfScope: null,
      constraints: null,
      unresolvedQuestions: null,
    })) as typeof fetch;

  try {
    await assert.rejects(
      () =>
        ollamaChat("Remove the Packages tab from the sidebar.", {
          requirePackageSemantics: true,
          concreteOperationMessage:
            "Remove the Packages tab from the sidebar.",
        }),
      /current-request Package Semantics fidelity/,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("does not reconcile vague requests", async () => {
  globalThis.fetch = (async () => responseWith(null)) as typeof fetch;

  try {
    await assert.rejects(
      () =>
        ollamaChat("Make the navigation better.", {
          requirePackageSemantics: true,
          concreteOperationMessage: "Make the navigation better.",
        }),
      /requires non-null Package Semantics/,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});
