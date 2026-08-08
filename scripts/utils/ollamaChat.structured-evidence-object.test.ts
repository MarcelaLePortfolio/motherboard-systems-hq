import assert from "node:assert/strict";
import test from "node:test";

import { ollamaChat } from "./ollamaChat";

test(
  "ollamaChat accepts a bounded structured evidence object",
  async () => {
    const originalFetch = globalThis.fetch;

    globalThis.fetch = (async () => ({
      ok: true,
      status: 200,
      statusText: "OK",
      json: async () => ({
        response: JSON.stringify({
          reply: "Conclusion.",
          explanationStatus: "optional",
          supportSourceReferences: [
            {
              type: "project_context_excerpt",
              relativePath:
                "server/matilda-chat-workflow.ts",
              lineNumber: 155,
            },
          ],
          evidence: {
            text:
              "The workflow excerpt shows that ollamaChat is invoked at the semantic seam.",
            supportSourceReferences: [
              {
                type: "project_context_excerpt",
                relativePath:
                  "server/matilda-chat-workflow.ts",
                lineNumber: 155,
              },
            ],
          },
          durableInterpretation:
            "Durable interpretation.",
        }),
      }),
    })) as typeof globalThis.fetch;

    try {
      const result = await ollamaChat(
        "Question.",
        {
          projectContextExcerpts: [
            {
              relativePath:
                "server/matilda-chat-workflow.ts",
              lineNumber: 155,
              excerpt:
                "const ollamaResult = await ollamaChat(message, {",
              provenance:
                "git_tracked_project_file",
              authorityStatus:
                "candidate_evidence_not_authority",
            },
          ],
        },
      );

      assert.deepEqual(result.evidence, {
        text:
          "The workflow excerpt shows that ollamaChat is invoked at the semantic seam.",
        supportSourceReferences: [
          {
            type: "project_context_excerpt",
            relativePath:
              "server/matilda-chat-workflow.ts",
            lineNumber: 155,
          },
        ],
      });
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "ollamaChat accepts null structured evidence",
  async () => {
    const originalFetch = globalThis.fetch;

    globalThis.fetch = (async () => ({
      ok: true,
      status: 200,
      statusText: "OK",
      json: async () => ({
        response: JSON.stringify({
          reply: "Conclusion.",
          explanationStatus: "optional",
          supportSourceReferences: [],
          evidence: null,
          durableInterpretation:
            "Durable interpretation.",
        }),
      }),
    })) as typeof globalThis.fetch;

    try {
      const result =
        await ollamaChat("Question.");

      assert.equal(result.evidence, null);
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "ollamaChat fails closed when evidence references an unsupplied source",
  async () => {
    const originalFetch = globalThis.fetch;

    globalThis.fetch = (async () => ({
      ok: true,
      status: 200,
      statusText: "OK",
      json: async () => ({
        response: JSON.stringify({
          reply: "Conclusion.",
          explanationStatus: "optional",
          supportSourceReferences: [],
          evidence: {
            text: "Unsupported evidence.",
            supportSourceReferences: [
              {
                type: "project_context_excerpt",
                relativePath:
                  "server/not-supplied.ts",
                lineNumber: 999,
              },
            ],
          },
          durableInterpretation:
            "Durable interpretation.",
        }),
      }),
    })) as typeof globalThis.fetch;

    try {
      await assert.rejects(
        () => ollamaChat("Question."),
        /evidence project-context support reference that was not supplied/i,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "ollamaChat rejects evidence text without support references",
  async () => {
    const originalFetch = globalThis.fetch;

    globalThis.fetch = (async () => ({
      ok: true,
      status: 200,
      statusText: "OK",
      json: async () => ({
        response: JSON.stringify({
          reply: "Conclusion.",
          explanationStatus: "optional",
          supportSourceReferences: [],
          evidence: {
            text: "Evidence without support.",
            supportSourceReferences: [],
          },
          durableInterpretation:
            "Durable interpretation.",
        }),
      }),
    })) as typeof globalThis.fetch;

    try {
      await assert.rejects(
        () => ollamaChat("Question."),
        /evidence text without support references/i,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
