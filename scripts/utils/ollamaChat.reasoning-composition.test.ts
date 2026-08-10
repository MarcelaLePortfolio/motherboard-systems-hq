import assert from "node:assert/strict";
import test from "node:test";

import { ollamaChat } from "./ollamaChat";

test(
  "ollamaChat preserves the ordered Reasoning Composition contract",
  async () => {
    const originalFetch = globalThis.fetch;
    let requestBody: Record<string, unknown> | null = null;

    globalThis.fetch = (async (_url, init) => {
      requestBody = JSON.parse(String(init?.body ?? "{}"));

      return {
        ok: true,
        status: 200,
        statusText: "OK",
        json: async () => ({
          response: JSON.stringify({
          investigationLifecycle: null,
            reply: "The workflow remains the preferred approach because it preserves the validated architectural boundary.",
            explanationStatus: "optional",
            selectedContextSegments: [],
            supportSourceReferences: [],
            evidence: null,
            durableInterpretation:
              "The user requested reasoning for the previous recommendation.",
          }),
        }),
      } as Response;
    }) as typeof globalThis.fetch;

    try {
      await ollamaChat("Why do you recommend that?", {
        priorExplanationEvidenceStatus: "sufficient",
      });

      const prompt = String(requestBody?.prompt ?? "");

      assert.match(
        prompt,
        /For a permitted explanation, compose the reasoning in this order/,
      );

      assert.match(
        prompt,
        /1\. Begin with the conclusion or recommendation being explained/,
      );

      assert.match(
        prompt,
        /2\. State the governing rationale/,
      );

      assert.match(
        prompt,
        /3\. Identify material tradeoffs/,
      );

      assert.match(
        prompt,
        /4\. State material uncertainty/,
      );

      assert.match(
        prompt,
        /Do not turn reasoning composition into an evidence inventory/,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
