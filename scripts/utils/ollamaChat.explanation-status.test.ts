import assert from "node:assert/strict";
import test from "node:test";

import { ollamaChat } from "./ollamaChat";

test(
  "ollamaChat returns schema-constrained Explanation Status from one invocation",
  async () => {
    const originalFetch = globalThis.fetch;
    let invocationCount = 0;
    let requestBody: Record<string, any> | null = null;

    globalThis.fetch = (async (
      _input: string | URL | Request,
      init?: RequestInit,
    ) => {
      invocationCount += 1;
      requestBody = JSON.parse(
        String(init?.body ?? "{}"),
      ) as Record<string, any>;

      return {
        ok: true,
        status: 200,
        statusText: "OK",
        json: async () => ({
          response: JSON.stringify({
            reply:
              "The current architecture supports a bounded implementation attempt.",
            explanationStatus: "optional",
            supportSourceReferences: [],
            durableInterpretation:
              "The user is evaluating whether the current architecture is ready for a bounded implementation attempt.",
          }),
        }),
      } as Response;
    }) as typeof globalThis.fetch;

    try {
      const result = await ollamaChat(
        "Can we proceed with the bounded implementation?",
      );

      assert.equal(invocationCount, 1);

      assert.deepEqual(
        requestBody?.format?.required,
        [
          "reply",
          "explanationStatus",
          "supportSourceReferences",
          "durableInterpretation",
        ],
      );

      assert.deepEqual(
        requestBody?.format?.properties?.explanationStatus?.enum,
        ["optional", "recommended"],
      );

      assert.equal(
        result.reply,
        "The current architecture supports a bounded implementation attempt.",
      );

      assert.equal(
        result.explanationStatus,
        "optional",
      );

      assert.equal(
        result.durableInterpretation,
        "The user is evaluating whether the current architecture is ready for a bounded implementation attempt.",
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "ollamaChat fails closed when Explanation Status is invalid",
  async () => {
    const originalFetch = globalThis.fetch;

    globalThis.fetch = (async () => ({
      ok: true,
      status: 200,
      statusText: "OK",
      json: async () => ({
        response: JSON.stringify({
          reply: "Conclusion.",
          explanationStatus: "required",
          supportSourceReferences: [],
          durableInterpretation:
            "Durable interpretation.",
        }),
      }),
    })) as typeof globalThis.fetch;

    try {
      await assert.rejects(
        () => ollamaChat("Question."),
        /invalid explanation status/i,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
