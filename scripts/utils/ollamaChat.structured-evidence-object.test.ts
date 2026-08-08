import assert from "node:assert/strict";
import test from "node:test";

import { ollamaChat } from "./ollamaChat";

const suppliedExcerpt =
  "const ollamaResult = await ollamaChat(message, {";

const projectContext = {
  projectContextExcerpts: [
    {
      relativePath: "server/matilda-chat-workflow.ts",
      lineNumber: 155,
      excerpt: suppliedExcerpt,
      provenance: "git_tracked_project_file" as const,
      authorityStatus:
        "candidate_evidence_not_authority" as const,
    },
  ],
};

test(
  "ollamaChat accepts paired project-context evidence",
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
            sources: [
              {
                reference: {
                  type: "project_context_excerpt",
                  relativePath:
                    "server/matilda-chat-workflow.ts",
                  lineNumber: 155,
                },
                excerpt: suppliedExcerpt,
              },
            ],
          },
          durableInterpretation:
            "Durable interpretation.",
        }),
      }),
    })) as typeof globalThis.fetch;

    try {
      const result =
        await ollamaChat("Question.", projectContext);

      assert.deepEqual(result.evidence, {
        sources: [
          {
            reference: {
              type: "project_context_excerpt",
              relativePath:
                "server/matilda-chat-workflow.ts",
              lineNumber: 155,
            },
            excerpt: suppliedExcerpt,
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
      const result = await ollamaChat("Question.");
      assert.equal(result.evidence, null);
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "ollamaChat fails closed on unsupplied evidence source",
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
            sources: [
              {
                reference: {
                  type: "project_context_excerpt",
                  relativePath: "server/not-supplied.ts",
                  lineNumber: 999,
                },
                excerpt: "not supplied",
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
        () => ollamaChat("Question.", projectContext),
        /evidence project-context source that was not supplied/i,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "ollamaChat fails closed on non-exact evidence excerpt",
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
            sources: [
              {
                reference: {
                  type: "project_context_excerpt",
                  relativePath:
                    "server/matilda-chat-workflow.ts",
                  lineNumber: 155,
                },
                excerpt: "A model-authored paraphrase.",
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
        () => ollamaChat("Question.", projectContext),
        /does not exactly match/i,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "ollamaChat rejects non-null evidence with zero sources",
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
            sources: [],
          },
          durableInterpretation:
            "Durable interpretation.",
        }),
      }),
    })) as typeof globalThis.fetch;

    try {
      await assert.rejects(
        () => ollamaChat("Question.", projectContext),
        /evidence without sources/i,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "ollamaChat deterministically removes duplicate evidence sources",
  async () => {
    const originalFetch = globalThis.fetch;

    const source = {
      reference: {
        type: "project_context_excerpt",
        relativePath:
          "server/matilda-chat-workflow.ts",
        lineNumber: 155,
      },
      excerpt: suppliedExcerpt,
    };

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
            sources: [source, source],
          },
          durableInterpretation:
            "Durable interpretation.",
        }),
      }),
    })) as typeof globalThis.fetch;

    try {
      const result =
        await ollamaChat("Question.", projectContext);

      assert.equal(result.evidence?.sources.length, 1);
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
