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

test(
  "parsed selected-context observer fires before invalid membership fails closed",
  async () => {
    const modelSelectedSegment = {
      relativePath: "docs/model-authored.md",
      sourceStartLine: 99,
      sourceEndLine: 101,
    };

    globalThis.fetch = async () =>
      new Response(
        JSON.stringify({
          response: JSON.stringify({
            reply: "Candidate response.",
            explanationStatus: "optional",
            selectedContextSegments: [modelSelectedSegment],
            supportSourceReferences: [],
            evidence: null,
            investigationLifecycle: null,
            durableInterpretation: "Candidate interpretation.",
          }),
        }),
        {
          status: 200,
          headers: { "content-type": "application/json" },
        },
      );

    let observed:
      readonly MatildaSelectedContextSegment[] | undefined;

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
          observeParsedSelectedContextSegments: (segments) => {
            observed = [...segments];
          },
        }),
      /selected context segment that was not supplied/,
    );

    assert.deepEqual(observed, [modelSelectedSegment]);
  },
);
