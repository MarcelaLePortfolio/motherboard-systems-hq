import assert from "node:assert/strict";
import test from "node:test";

import {
  ollamaChat,
} from "./ollamaChat";

const originalFetch = globalThis.fetch;

test.afterEach(() => {
  globalThis.fetch = originalFetch;
});

function acceptedResponse() {
  return {
    reply: "The status workspace becomes active when activeWorkspace equals status.",
    explanationStatus: "optional",
    selectedContextSegments: [],
    supportSourceReferences: [],
    evidence: null,
    investigationLifecycle: null,
    packageSemantics: null,
    durableInterpretation:
      "The user asked how the status workspace becomes active.",
  };
}

test(
  "retrieval origin is presented as non-semantic candidate provenance without changing child identity fields",
  async () => {
    let observedPrompt = "";

    globalThis.fetch = async (_input, init) => {
      assert.equal(typeof init?.body, "string");

      const request = JSON.parse(
        init?.body as string,
      ) as {
        prompt?: unknown;
      };

      observedPrompt =
        typeof request.prompt === "string"
          ? request.prompt
          : "";

      return new Response(
        JSON.stringify({
          response: JSON.stringify(
            acceptedResponse(),
          ),
        }),
        {
          status: 200,
          headers: {
            "content-type": "application/json",
          },
        },
      );
    };

    await ollamaChat(
      "How does the status workspace become active?",
      {
        projectId: "hq",
        projectDisplayName:
          "Motherboard Systems HQ",
        history: [],
        projectContextSegmentCandidates: [
          {
            relativePath:
              "client/src/workspace/StatusWorkspace.tsx",
            parentRelativePath:
              "client/src/workspace/StatusWorkspace.tsx",
            parentLineNumber: 10,
            sourceStartLine: 9,
            sourceEndLine: 11,
            text:
              'const isActive = activeWorkspace === "status";',
            retrievalOrigin: "lexical",
          },
          {
            relativePath:
              "client/src/workspace/ModeKind.ts",
            parentRelativePath:
              "client/src/workspace/ModeKind.ts",
            parentLineNumber: 2,
            sourceStartLine: 1,
            sourceEndLine: 4,
            text:
              'export type ModeKind = "status" | "archive" | "settings";',
            retrievalOrigin: "structural",
          },
        ],
      },
    );

    assert.match(
      observedPrompt,
      /Retrieval origin records only how runtime discovered a candidate\. It does not determine semantic relevance\./,
    );

    assert.match(
      observedPrompt,
      /Do not select or reject a child segment merely because of its retrieval origin\./,
    );

    assert.match(
      observedPrompt,
      /retrieval origin = lexical/,
    );

    assert.match(
      observedPrompt,
      /retrieval origin = structural/,
    );

    assert.match(
      observedPrompt,
      /relativePath = client\/src\/workspace\/StatusWorkspace\.tsx/,
    );

    assert.match(
      observedPrompt,
      /sourceStartLine = 9/,
    );

    assert.match(
      observedPrompt,
      /sourceEndLine = 11/,
    );
  },
);

test(
  "retrieval origin is not added to the model-authored selectedContextSegments identity schema",
  async () => {
    let requestBody = "";

    globalThis.fetch = async (_input, init) => {
      requestBody =
        typeof init?.body === "string"
          ? init.body
          : "";

      return new Response(
        JSON.stringify({
          response: JSON.stringify(
            acceptedResponse(),
          ),
        }),
        {
          status: 200,
          headers: {
            "content-type": "application/json",
          },
        },
      );
    };

    await ollamaChat(
      "How does the status workspace become active?",
      {
        projectId: "hq",
        history: [],
        projectContextSegmentCandidates: [
          {
            relativePath:
              "client/src/workspace/StatusWorkspace.tsx",
            parentRelativePath:
              "client/src/workspace/StatusWorkspace.tsx",
            parentLineNumber: 10,
            sourceStartLine: 9,
            sourceEndLine: 11,
            text:
              'const isActive = activeWorkspace === "status";',
            retrievalOrigin: "lexical",
          },
        ],
      },
    );

    const parsed = JSON.parse(
      requestBody,
    ) as {
      format?: {
        properties?: {
          selectedContextSegments?: {
            items?: {
              required?: string[];
              properties?: Record<
                string,
                unknown
              >;
            };
          };
        };
      };
    };

    const selectedItem =
      parsed.format?.properties
        ?.selectedContextSegments?.items;

    assert.deepEqual(
      selectedItem?.required,
      [
        "relativePath",
        "sourceStartLine",
        "sourceEndLine",
      ],
    );

    assert.equal(
      Object.prototype.hasOwnProperty.call(
        selectedItem?.properties ?? {},
        "retrievalOrigin",
      ),
      false,
    );
  },
);
