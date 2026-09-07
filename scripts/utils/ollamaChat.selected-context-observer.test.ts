import assert from "node:assert/strict";
import test from "node:test";

import {
  ollamaChat,
  type MatildaSelectedContextSegment,
} from "./ollamaChat";

const originalFetch = globalThis.fetch;

function installResponse(
  structuredResponse: Record<string, unknown>,
): void {
  globalThis.fetch = async () =>
    new Response(
      JSON.stringify({
        response: JSON.stringify(structuredResponse),
      }),
      {
        status: 200,
        headers: {
          "content-type": "application/json",
        },
      },
    );
}

test.afterEach(() => {
  globalThis.fetch = originalFetch;
});

function baseResponse(
  selectedContextCandidatePositions: unknown[],
  supportSourceReferences: unknown[] = [],
) {
  return {
    reply: "The relevant implementation behavior is supported.",
    explanationStatus: "optional",
    selectedContextCandidatePositions,
    supportSourceReferences,
    evidence: null,
    investigationLifecycle: null,
    packageSemantics: null,
    durableInterpretation:
      "The relevant implementation behavior is supported.",
  };
}

const suppliedExcerpt = {
  relativePath: "docs/adaptive-detail.md",
  lineNumber: 10,
  excerpt: "Relevant implementation behavior.",
  provenance: "git_tracked_project_file" as const,
  authorityStatus:
    "candidate_evidence_not_authority" as const,
};

const suppliedCandidate = {
  relativePath: "docs/adaptive-detail.md",
  parentRelativePath: "docs/adaptive-detail.md",
  parentLineNumber: 10,
  sourceStartLine: 10,
  sourceEndLine: 12,
  text: "Relevant implementation behavior.",
};

const selectedIdentity = {
  relativePath: suppliedCandidate.relativePath,
  sourceStartLine: suppliedCandidate.sourceStartLine,
  sourceEndLine: suppliedCandidate.sourceEndLine,
};

test(
  "normal production-style invocation remains valid without an observer",
  async () => {
    installResponse(baseResponse([0]));

    const result = await ollamaChat("Question.", {
      projectContextExcerpts: [suppliedExcerpt],
      projectContextSegmentCandidates: [suppliedCandidate],
    });

    assert.equal(
      result.reply,
      "The relevant implementation behavior is supported.",
    );
    assert.equal("selectedContextSegments" in result, false);
    assert.deepEqual(result.supportSourceReferences, [
      {
        type: "project_context_excerpt",
        relativePath: "docs/adaptive-detail.md",
        lineNumber: 10,
      },
    ]);
  },
);

test(
  "observer receives only validated deterministically deduplicated selections",
  async () => {
    installResponse(
      baseResponse([0, 0]),
    );

    let observed:
      readonly MatildaSelectedContextSegment[] | undefined;

    await ollamaChat("Question.", {
      projectContextExcerpts: [suppliedExcerpt],
      projectContextSegmentCandidates: [suppliedCandidate],
      observeValidatedSelectedContextSegments: (segments) => {
        observed = segments;
      },
    });

    assert.deepEqual(observed, [selectedIdentity]);
  },
);

test(
  "invented selection fails before observer invocation",
  async () => {
    installResponse(
      baseResponse([1]),
    );

    let observerCalled = false;

    await assert.rejects(
      () =>
        ollamaChat("Question.", {
          projectContextExcerpts: [suppliedExcerpt],
          projectContextSegmentCandidates: [suppliedCandidate],
          observeValidatedSelectedContextSegments: () => {
            observerCalled = true;
          },
        }),
      /selected context candidate position that was not supplied/,
    );

    assert.equal(observerCalled, false);
  },
);

test(
  "model-authored project support fails before observer invocation",
  async () => {
    installResponse(
      baseResponse([], [
        {
          type: "project_context_excerpt",
          relativePath: "docs/adaptive-detail.md",
          lineNumber: 10,
        },
      ]),
    );

    let observerCalled = false;

    await assert.rejects(
      () =>
        ollamaChat("Question.", {
          projectContextExcerpts: [suppliedExcerpt],
          projectContextSegmentCandidates: [suppliedCandidate],
          observeValidatedSelectedContextSegments: () => {
            observerCalled = true;
          },
        }),
      /model-authored project-context support provenance/,
    );

    assert.equal(observerCalled, false);
  },
);
