import assert from "node:assert/strict";
import test from "node:test";

import {
  ollamaChat,
  type MatildaSelectedContextSegment,
} from "./ollamaChat";

const originalFetch = globalThis.fetch;

test.afterEach(() => {
  globalThis.fetch = originalFetch;
});

const firstCandidate = {
  relativePath: "server/first.ts",
  parentRelativePath: "server/first.ts",
  parentLineNumber: 10,
  sourceStartLine: 10,
  sourceEndLine: 12,
  text: "First candidate.",
  retrievalOrigin: "lexical" as const,
};

const secondCandidate = {
  relativePath: "server/second.ts",
  parentRelativePath: "server/second.ts",
  parentLineNumber: 40,
  sourceStartLine: 40,
  sourceEndLine: 45,
  text: "Second candidate.",
  retrievalOrigin: "structural" as const,
};

function response(
  selectedContextCandidatePositions: unknown,
) {
  return new Response(
    JSON.stringify({
      response: JSON.stringify({
        reply: "The second candidate is material.",
        explanationStatus: "optional",
        selectedContextCandidatePositions,
        supportSourceReferences: [],
        evidence: null,
        investigationLifecycle: null,
        packageSemantics: null,
        durableInterpretation:
          "The second supplied candidate materially supports the response.",
      }),
    }),
    {
      status: 200,
      headers: {
        "content-type": "application/json",
      },
    },
  );
}

test(
  "production positional selection resolves runtime-owned identity",
  async () => {
    globalThis.fetch = async () => response([1]);

    let observed:
      readonly MatildaSelectedContextSegment[] | undefined;

    const result = await ollamaChat(
      "Which candidate matters?",
      {
        projectContextSegmentCandidates: [
          firstCandidate,
          secondCandidate,
        ],
        projectContextExcerpts: [
          {
            relativePath: "server/first.ts",
            lineNumber: 10,
            excerpt: "First candidate.",
            provenance: "git_tracked_project_file" as const,
            authorityStatus:
              "candidate_evidence_not_authority" as const,
          },
          {
            relativePath: "server/second.ts",
            lineNumber: 40,
            excerpt: "Second candidate.",
            provenance: "git_tracked_project_file" as const,
            authorityStatus:
              "candidate_evidence_not_authority" as const,
          },
        ],
        observeValidatedSelectedContextSegments:
          (segments) => {
            observed = segments;
          },
      },
    );

    assert.deepEqual(observed, [
      {
        relativePath: "server/second.ts",
        sourceStartLine: 40,
        sourceEndLine: 45,
      },
    ]);

    assert.deepEqual(result.supportSourceReferences, [
      {
        type: "project_context_excerpt",
        relativePath: "server/second.ts",
        lineNumber: 40,
      },
    ]);
  },
);

test(
  "duplicate positions are deterministically deduplicated",
  async () => {
    globalThis.fetch = async () => response([1, 1, 1]);

    let observed:
      readonly MatildaSelectedContextSegment[] | undefined;

    await ollamaChat(
      "Which candidate matters?",
      {
        projectContextSegmentCandidates: [
          firstCandidate,
          secondCandidate,
        ],
        projectContextExcerpts: [
          {
            relativePath: "server/first.ts",
            lineNumber: 10,
            excerpt: "First candidate.",
            provenance: "git_tracked_project_file" as const,
            authorityStatus:
              "candidate_evidence_not_authority" as const,
          },
          {
            relativePath: "server/second.ts",
            lineNumber: 40,
            excerpt: "Second candidate.",
            provenance: "git_tracked_project_file" as const,
            authorityStatus:
              "candidate_evidence_not_authority" as const,
          },
        ],
        observeValidatedSelectedContextSegments:
          (segments) => {
            observed = segments;
          },
      },
    );

    assert.deepEqual(observed, [
      {
        relativePath: "server/second.ts",
        sourceStartLine: 40,
        sourceEndLine: 45,
      },
    ]);
  },
);

test(
  "out-of-range position fails closed",
  async () => {
    globalThis.fetch = async () => response([2]);

    await assert.rejects(
      () =>
        ollamaChat("Which candidate matters?", {
          projectContextSegmentCandidates: [
            firstCandidate,
            secondCandidate,
          ],
        }),
      /candidate position that was not supplied in this invocation/,
    );
  },
);

test(
  "non-integer position fails closed",
  async () => {
    globalThis.fetch = async () => response([0.5]);

    await assert.rejects(
      () =>
        ollamaChat("Which candidate matters?", {
          projectContextSegmentCandidates: [
            firstCandidate,
          ],
        }),
      /malformed selected context candidate position/,
    );
  },
);
