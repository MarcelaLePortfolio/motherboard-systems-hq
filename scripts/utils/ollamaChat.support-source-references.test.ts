import assert from "node:assert/strict";
import test from "node:test";

import { ollamaChat } from "./ollamaChat";

test(
  "ollamaChat accepts bounded conversation and project support references",
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
              type: "conversation_turn",
              sourceTurnId: "turn-123",
            },
            {
              type: "project_context_excerpt",
              relativePath: "server/matilda-chat-workflow.ts",
              lineNumber: 155,
            },
          ],
          durableInterpretation:
            "Durable interpretation.",
        }),
      }),
    })) as typeof globalThis.fetch;

    try {
      const result = await ollamaChat("Question.");

      assert.deepEqual(
        result.supportSourceReferences,
        [
          {
            type: "conversation_turn",
            sourceTurnId: "turn-123",
          },
          {
            type: "project_context_excerpt",
            relativePath: "server/matilda-chat-workflow.ts",
            lineNumber: 155,
          },
        ],
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "ollamaChat fails closed on malformed conversation support reference",
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
              type: "conversation_turn",
            },
          ],
          durableInterpretation:
            "Durable interpretation.",
        }),
      }),
    })) as typeof globalThis.fetch;

    try {
      await assert.rejects(
        () => ollamaChat("Question."),
        /malformed conversation support reference/i,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "ollamaChat fails closed on malformed project support reference",
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
              relativePath: "server/matilda-chat-workflow.ts",
            },
          ],
          durableInterpretation:
            "Durable interpretation.",
        }),
      }),
    })) as typeof globalThis.fetch;

    try {
      await assert.rejects(
        () => ollamaChat("Question."),
        /malformed project-context support reference/i,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "ollamaChat fails closed on unknown support reference type",
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
              type: "unknown",
            },
          ],
          durableInterpretation:
            "Durable interpretation.",
        }),
      }),
    })) as typeof globalThis.fetch;

    try {
      await assert.rejects(
        () => ollamaChat("Question."),
        /unknown support source reference type/i,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
