import assert from "node:assert/strict";
import test from "node:test";

import { ollamaChat } from "./ollamaChat";

test(
  "ollamaChat receives sufficient prior-evidence status without adding another invocation",
  async () => {
    const originalFetch = globalThis.fetch;
    let calls = 0;
    let body: Record<string, any> | null = null;

    globalThis.fetch = (async (_url, init) => {
      calls += 1;
      body = JSON.parse(
        String(init?.body ?? "{}"),
      );

      return {
        ok: true,
        status: 200,
        statusText: "OK",
        json: async () => ({
          response: JSON.stringify({
            reply:
              "The prior conclusion can be explained from its established support.",
            explanationStatus: "optional",
            supportSourceReferences: [],
            evidence: null,
            durableInterpretation:
              "The user requested explanation of a supported prior conclusion.",
          }),
        }),
      } as Response;
    }) as typeof globalThis.fetch;

    try {
      await ollamaChat(
        "Why?",
        {
          priorExplanationEvidenceStatus:
            "sufficient",
        },
      );

      assert.equal(calls, 1);

      const prompt = String(body?.prompt ?? "");

      assert.match(
        prompt,
        /Evidence status: sufficient/,
      );

      assert.match(
        prompt,
        /persisted validated support provenance/,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "ollamaChat receives insufficient prior-evidence status and forbids invented justification",
  async () => {
    const originalFetch = globalThis.fetch;
    let calls = 0;
    let body: Record<string, any> | null = null;

    globalThis.fetch = (async (_url, init) => {
      calls += 1;
      body = JSON.parse(
        String(init?.body ?? "{}"),
      );

      return {
        ok: true,
        status: 200,
        statusText: "OK",
        json: async () => ({
          response: JSON.stringify({
            reply:
              "Sufficient supporting justification is not available from the established evidence.",
            explanationStatus: "optional",
            supportSourceReferences: [],
            evidence: null,
            durableInterpretation:
              "The requested prior justification is unsupported by persisted evidence.",
          }),
        }),
      } as Response;
    }) as typeof globalThis.fetch;

    try {
      await ollamaChat(
        "Why?",
        {
          priorExplanationEvidenceStatus:
            "insufficient",
        },
      );

      assert.equal(calls, 1);

      const prompt = String(body?.prompt ?? "");

      assert.match(
        prompt,
        /Evidence status: insufficient/,
      );

      assert.match(
        prompt,
        /do not invent an engineering justification/i,
      );

      assert.match(
        prompt,
        /sufficient supporting justification is not available/i,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "ollamaChat treats unavailable prior provenance as unsafe for justification",
  async () => {
    const originalFetch = globalThis.fetch;
    let body: Record<string, any> | null = null;

    globalThis.fetch = (async (_url, init) => {
      body = JSON.parse(
        String(init?.body ?? "{}"),
      );

      return {
        ok: true,
        status: 200,
        statusText: "OK",
        json: async () => ({
          response: JSON.stringify({
            reply:
              "Sufficient supporting justification is not available from the established evidence.",
            explanationStatus: "optional",
            supportSourceReferences: [],
            evidence: null,
            durableInterpretation:
              "Prior support provenance is unavailable.",
          }),
        }),
      } as Response;
    }) as typeof globalThis.fetch;

    try {
      await ollamaChat(
        "Explain that.",
        {
          priorExplanationEvidenceStatus:
            "unavailable",
        },
      );

      const prompt = String(body?.prompt ?? "");

      assert.match(
        prompt,
        /Evidence status: unavailable/,
      );

      assert.match(
        prompt,
        /do not invent an engineering justification/i,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
