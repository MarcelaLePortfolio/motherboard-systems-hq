import assert from "node:assert/strict";
import test from "node:test";

import { ollamaChat } from "./ollamaChat";

test(
  "ollamaChat preserves bounded Boundary Composition instructions",
  async () => {
    const originalFetch = globalThis.fetch;
    let invocationCount = 0;
    let requestBody: Record<string, unknown> | null = null;

    globalThis.fetch = (async (
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
              "The test verifies deterministic deduplication.",
            explanationStatus: "optional",
            selectedContextSegments: [],
            supportSourceReferences: [],
            evidence: null,
            durableInterpretation:
              "The user asked what the test verifies.",
          }),
        }),
      } as Response;
    }) as typeof globalThis.fetch;

    try {
      const result = await ollamaChat(
        "What does this test verify?",
      );

      const prompt = String(
        requestBody?.prompt ?? "",
      );

      assert.equal(invocationCount, 1);

      assert.match(
        prompt,
        /Preserve material uncertainty, scope boundaries, and evidence distinctions when they affect the conclusion/,
      );

      assert.match(
        prompt,
        /Do not surface boundaries, deferred work, or unresolved limits that do not materially affect the immediate conclusion or requested answer/,
      );

      assert.match(
        prompt,
        /Avoid restating already-established context unless it materially affects the current response/,
      );

      assert.equal(
        result.reply,
        "The test verifies deterministic deduplication.",
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
