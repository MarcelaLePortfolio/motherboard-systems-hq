import test from "node:test";
import assert from "node:assert/strict";

import { ollamaChat } from "./ollamaChat";

test(
  "ollamaChat preserves Reasoning Classification instructions in the reply contract",
  async () => {
    const originalFetch = globalThis.fetch;
    let invocationCount = 0;
    let requestBody: Record<string, unknown> | null = null;

    globalThis.fetch = async (
      _input: string | URL | Request,
      init?: RequestInit,
    ) => {
      invocationCount += 1;
      requestBody = JSON.parse(
        String(init?.body ?? "{}"),
      ) as Record<string, unknown>;

      return {
        ok: true,
        status: 200,
        statusText: "OK",
        json: async () => ({
          response: JSON.stringify({
            reply:
              "The current conclusion is safe to act on.\n\nReasoning Status: Optional\n\nSupporting reasoning remains available.",
            durableInterpretation:
              "Reasoning Classification is implemented within the existing reply contract.",
          }),
        }),
      } as Response;
    };

    try {
      const result = await ollamaChat(
        "Assess the current implementation.",
      );

      const prompt = String(requestBody?.prompt ?? "");

      assert.equal(invocationCount, 1);

      assert.ok(
        prompt.includes(
          "Immediately after the opening summary, you MUST include exactly one standalone reasoning classification line.",
        ),
      );

      assert.ok(
        prompt.includes(
          "Use exactly one of these two forms and no variation: Reasoning Status: Optional OR Reasoning Status: Recommended.",
        ),
      );

      assert.ok(
        prompt.includes(
          "The reasoning classification line is mandatory even when no supporting reasoning follows.",
        ),
      );

      assert.ok(
        prompt.includes(
          "Reasoning Status: Optional is the default.",
        ),
      );

      assert.ok(
        prompt.includes(
          "Use Reasoning Status: Recommended only when skipping the supporting reasoning is likely to materially change the user's next engineering decision",
        ),
      );

      assert.ok(
        prompt.includes(
          "Do not classify reasoning as Recommended merely because evidence exists, because the work was substantial, or because additional explanation is available.",
        ),
      );

      assert.ok(
        result.reply.includes("Reasoning Status: Optional"),
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
