import test from "node:test";
import assert from "node:assert/strict";

import { ollamaChat } from "./ollamaChat";

test(
  "ollamaChat includes Summary Composition instructions in the reply contract",
  async () => {
    const originalFetch = globalThis.fetch;
    let requestBody: Record<string, unknown> | null = null;

    globalThis.fetch = async (_input, init) => {
      requestBody = JSON.parse(String(init?.body ?? "{}"));

      return {
        ok: true,
        status: 200,
        statusText: "OK",
        json: async () => ({
          response: JSON.stringify({
            reply: "Summary paragraph. Supporting reasoning follows.",
            durableInterpretation:
              "Summary Composition prompt contract present.",
          }),
        }),
      } as Response;
    };

    try {
      await ollamaChat("Test");

      const prompt = String(requestBody?.prompt ?? "");

      assert.ok(
        prompt.includes(
          "Lead with a concise natural-language summary"
        )
      );
      assert.ok(
        prompt.includes(
          "Write the opening summary as a complete paragraph"
        )
      );
      assert.ok(
        prompt.includes(
          "After the opening summary, provide only the supporting detail needed for the current interaction."
        )
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  }
);
