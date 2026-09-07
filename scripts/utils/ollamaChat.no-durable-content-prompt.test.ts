import assert from "node:assert/strict";
import test from "node:test";

import { ollamaChat } from "./ollamaChat";

test(
  "pure conversational turns are instructed to author the absence of durable semantics without preserving the greeting itself",
  async () => {
    const originalFetch = globalThis.fetch;
    let requestBody: Record<string, unknown> | null = null;

    globalThis.fetch = async (
      _input: string | URL | Request,
      init?: RequestInit,
    ) => {
      requestBody = JSON.parse(
        String(init?.body ?? "{}"),
      ) as Record<string, unknown>;

      return {
        ok: true,
        status: 200,
        statusText: "OK",
        json: async () => ({
          response: JSON.stringify({
            reply: "Hey! What would you like to work on?",
            explanationStatus: "optional",
            selectedContextCandidatePositions: [],
            supportSourceReferences: [],
            evidence: null,
            investigationLifecycle: null,
            packageSemantics: null,
            durableInterpretation:
              "No durable user semantics were established in this turn.",
          }),
        }),
      } as Response;
    };

    try {
      const result = await ollamaChat("hey matilda");

      assert.equal(
        result.durableInterpretation,
        "No durable user semantics were established in this turn.",
      );

      assert.ok(requestBody);
      const prompt = String(
        (requestBody as Record<string, unknown>).prompt ?? "",
      );

      assert.match(
        prompt,
        /When the current turn establishes no durable user meaning, intent, decision, constraint, authorization, or unresolved question, still return a concise non-empty durableInterpretation stating only that no durable user semantics were established in this turn\./,
      );

      assert.match(
        prompt,
        /Do not turn the greeting, reassurance, filler, or other conversational-only content itself into durable user semantics\./,
      );

      assert.match(
        prompt,
        /Exclude greetings, reassurance, filler, stylistic flourishes, and internal implementation details themselves\./,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "empty durable interpretation remains fail-closed after the conversational-only prompt clarification",
  async () => {
    const originalFetch = globalThis.fetch;

    globalThis.fetch = async () =>
      ({
        ok: true,
        status: 200,
        statusText: "OK",
        json: async () => ({
          response: JSON.stringify({
            reply: "Hey!",
            explanationStatus: "optional",
            selectedContextCandidatePositions: [],
            supportSourceReferences: [],
            evidence: null,
            investigationLifecycle: null,
            packageSemantics: null,
            durableInterpretation: "",
          }),
        }),
      }) as Response;

    try {
      await assert.rejects(
        () => ollamaChat("hey matilda"),
        /empty durable interpretation/,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
