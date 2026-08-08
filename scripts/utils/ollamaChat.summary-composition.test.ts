import test from "node:test";
import assert from "node:assert/strict";

import { ollamaChat } from "./ollamaChat";

test(
  "ollamaChat preserves Summary Composition instructions in the reply contract",
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
              "The implementation is stable. Supporting detail follows only where needed.",
            explanationStatus: "optional",
            explanationStatus: "optional",
            supportSourceReferences: [],
            evidence: null,
            durableInterpretation:
              "Summary Composition is implemented within the existing reply prompt contract.",
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
          "Lead with a concise natural-language summary that communicates the conclusion, recommendation, or current assessment.",
        ),
      );

      assert.ok(
        prompt.includes(
          "Write the opening summary as a complete paragraph rather than shorthand or bullet points whenever practical.",
        ),
      );

      assert.ok(
        prompt.includes(
          "After the opening summary, include only the supporting detail needed for the current interaction.",
        ),
      );

      assert.ok(
        prompt.includes(
          "Preserve material uncertainty, scope boundaries, and evidence distinctions when they affect the conclusion.",
        ),
      );

      assert.ok(
        prompt.includes(
          "Avoid restating already-established context unless it materially affects the current response.",
        ),
      );

      assert.equal(
        result.reply,
        "The implementation is stable. Supporting detail follows only where needed.",
      );

      assert.equal(
        result.durableInterpretation,
        "Summary Composition is implemented within the existing reply prompt contract.",
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
