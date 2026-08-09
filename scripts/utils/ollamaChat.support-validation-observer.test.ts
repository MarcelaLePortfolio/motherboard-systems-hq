import assert from "node:assert/strict";
import test from "node:test";

import {
  ollamaChat,
  type MatildaSupportSourceReference,
} from "./ollamaChat";

const originalFetch = globalThis.fetch;

test.afterEach(() => {
  globalThis.fetch = originalFetch;
});

test(
  "support observer exposes parsed model-authored references before supplied-source validation",
  async () => {
    globalThis.fetch = async () =>
      new Response(
        JSON.stringify({
          response: JSON.stringify({
            reply: "Answer.",
            explanationStatus: "optional",
            selectedContextSegments: [],
            supportSourceReferences: [
              {
                type: "project_context_excerpt",
                relativePath: "docs/wrong.md",
                lineNumber: 999,
              },
            ],
            evidence: null,
            durableInterpretation:
              "The user requested an answer.",
          }),
        }),
        {
          status: 200,
          headers: {
            "content-type": "application/json",
          },
        },
      );

    let observed:
      readonly MatildaSupportSourceReference[] |
      undefined;

    await assert.rejects(
      () =>
        ollamaChat("Question.", {
          observeParsedSupportSourceReferences:
            (references) => {
              observed = [...references];
            },
        }),
      /project-context support reference that was not supplied/i,
    );

    assert.deepEqual(
      observed,
      [
        {
          type: "project_context_excerpt",
          relativePath: "docs/wrong.md",
          lineNumber: 999,
        },
      ],
    );
  },
);

test(
  "normal invocation remains unchanged without support observer",
  async () => {
    globalThis.fetch = async () =>
      new Response(
        JSON.stringify({
          response: JSON.stringify({
            reply: "Answer.",
            explanationStatus: "optional",
            selectedContextSegments: [],
            supportSourceReferences: [],
            evidence: null,
            durableInterpretation:
              "The user requested an answer.",
          }),
        }),
        {
          status: 200,
          headers: {
            "content-type": "application/json",
          },
        },
      );

    const result =
      await ollamaChat("Question.");

    assert.equal(result.reply, "Answer.");
  },
);
