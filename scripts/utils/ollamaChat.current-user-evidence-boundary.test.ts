import assert from "node:assert/strict";
import test from "node:test";

import { ollamaChat } from "./ollamaChat";

test(
  "ollamaChat presents current-user completed-action statements as conversational evidence without making them prior-turn provenance and preserves partial-scope distinctions",
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
            investigationLifecycle: null,
            packageSemantics: null,
            reply:
              "Your reported browser validation is current conversational evidence, while the repository evidence establishes the governing removal gate.",
            explanationStatus: "optional",
            selectedContextCandidatePositions: [],
            supportSourceReferences: [],
            evidence: null,
            durableInterpretation:
              "The user reports having personally completed browser validation.",
          }),
        }),
      } as Response;
    }) as typeof globalThis.fetch;

    try {
      await ollamaChat(
        "I personally validated the Executive Inbox in the browser.",
        {
          executionAuthorized: false,
        },
      );

      assert.equal(invocationCount, 1);

      const prompt = String(
        requestBody?.prompt ?? "",
      );

      assert.match(
        prompt,
        /Explicit first-person statements in the current user message about actions the user completed are user-supplied conversational evidence of those reported actions\./,
      );

      assert.match(
        prompt,
        /Evaluate that current-user evidence together with the other supplied evidence without inventing an additional validation process, authority requirement, or execution requirement that the supplied evidence does not establish\./,
      );

      assert.match(
        prompt,
        /When supplied evidence establishes only a subset of a required scope, preserve that subset distinction: treat the established portion as established and identify only the remaining uncovered scope as unresolved rather than describing the established portion itself as incomplete\./,
      );

      assert.match(
        prompt,
        /The current user message is not a prior conversation support source and must not be represented as conversation_turn provenance\./,
      );

      assert.match(
        prompt,
        /Do not claim that you personally performed or completed any action this workflow cannot execute\./,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
