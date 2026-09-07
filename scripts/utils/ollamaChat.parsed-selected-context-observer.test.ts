import assert from "node:assert/strict";
import test from "node:test";

import { ollamaChat } from "./ollamaChat";

const originalFetch = globalThis.fetch;

test.afterEach(() => {
  globalThis.fetch = originalFetch;
});

test(
  "parsed positional observer fires before invalid membership fails closed",
  async () => {
    globalThis.fetch = async () =>
      new Response(
        JSON.stringify({
          response: JSON.stringify({
            reply: "Candidate response.",
            explanationStatus: "optional",
            selectedContextCandidatePositions: [99],
            supportSourceReferences: [],
            evidence: null,
            investigationLifecycle: null,
            packageSemantics: null,
            durableInterpretation: "Candidate interpretation.",
          }),
        }),
        {
          status: 200,
          headers: { "content-type": "application/json" },
        },
      );

    let observed: readonly number[] | undefined;

    await assert.rejects(
      () =>
        ollamaChat("Question.", {
          projectContextSegmentCandidates: [
            {
              relativePath: "docs/supplied.md",
              parentRelativePath: "docs/supplied.md",
              parentLineNumber: 10,
              sourceStartLine: 10,
              sourceEndLine: 10,
              text: "Supplied candidate.",
            },
          ],
          observeParsedSelectedContextCandidatePositions:
            (positions) => {
              observed = [...positions];
            },
        }),
      /selected context candidate position that was not supplied/,
    );

    assert.deepEqual(observed, [99]);
  },
);
