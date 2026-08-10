import assert from "node:assert/strict";
import test from "node:test";

import { ollamaChat } from "./ollamaChat";

test(
  "explicit explanation requests preserve the engineering explanation contract",
  async () => {
    const originalFetch = globalThis.fetch;
    let body: Record<string, unknown> | null = null;
    let calls = 0;

    globalThis.fetch = (async (_url, init) => {
      calls++;

      body = JSON.parse(
        String(init?.body ?? "{}"),
      ) as Record<string, unknown>;

      return {
        ok: true,
        status: 200,
        statusText: "OK",
        json: async () => ({
          response: JSON.stringify({
          investigationLifecycle: null,
            reply:
              "The recommendation follows from the validated workflow boundary and the architectural constraints already established.",
            explanationStatus: "optional",
            selectedContextSegments: [],
            supportSourceReferences: [],
            evidence: null,
            durableInterpretation:
              "The user requested an explanation of the previous recommendation.",
          }),
        }),
      } as Response;
    }) as typeof globalThis.fetch;

    try {
      await ollamaChat(
        "Can you explain why you recommended that?",
        {
          history: [
            {
              userMessage:
                "Which implementation should we choose?",
              assistantReply:
                "I recommend preserving the existing workflow boundary.",
            },
          ],
        },
      );

      assert.equal(calls, 1);

      const prompt = String(body?.prompt ?? "");

      assert.match(
        prompt,
        /When the user explicitly asks why a previous conclusion was reached/,
      );

      assert.match(
        prompt,
        /Do not narrate hidden reasoning/,
      );

      assert.match(
        prompt,
        /Matilda: I recommend preserving the existing workflow boundary\./,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
