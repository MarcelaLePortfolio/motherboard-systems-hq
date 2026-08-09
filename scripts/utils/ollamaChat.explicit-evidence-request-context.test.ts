import assert from "node:assert/strict";
import test from "node:test";

import { ollamaChat } from "./ollamaChat";

test(
  "ollamaChat accepts explicitEvidenceRequest context without adding another invocation",
  async () => {
    const originalFetch = globalThis.fetch;
    let invocationCount = 0;

    globalThis.fetch = (async () => {
      invocationCount += 1;

      return {
        ok: true,
        status: 200,
        statusText: "OK",
        json: async () => ({
          response: JSON.stringify({
            reply: "Repository evidence is available.",
            explanationStatus: "optional",
            supportSourceReferences: [],
            evidence: null,
            durableInterpretation:
              "The user explicitly requested repository evidence.",
          }),
        }),
      } as Response;
    }) as typeof globalThis.fetch;

    try {
      const result = await ollamaChat(
        "Show me the repository evidence.",
        {
          explicitEvidenceRequest: true,
        },
      );

      assert.equal(invocationCount, 1);
      assert.equal(
        result.reply,
        "Repository evidence is available.",
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
