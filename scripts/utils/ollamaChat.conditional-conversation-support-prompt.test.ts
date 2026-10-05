import assert from "node:assert/strict";
import test from "node:test";

import { ollamaChat } from "./ollamaChat.js";

const POSITIVE_CONVERSATION_INSTRUCTION =
  "For conversation support, use type conversation_turn with the exact Conversation source identifier supplied in history.";

test(
  "empty history omits positive conversation-turn construction instruction while preserving negative safeguards",
  async () => {
    const originalFetch = globalThis.fetch;
    let prompt = "";

    globalThis.fetch = (async (_input, init) => {
      const body = JSON.parse(String(init?.body ?? "{}"));
      prompt = String(body.prompt ?? "");

      return new Response(
        JSON.stringify({
          response: JSON.stringify({
            reply: "No prior conversation support is available.",
            explanationStatus: "optional",
            selectedContextCandidatePositions: [],
            supportSourceReferences: [],
            evidence: null,
            investigationLifecycle: null,
            packageSemantics: null,
            durableInterpretation: "The user requested bounded support provenance.",
          }),
        }),
        {
          status: 200,
          headers: { "content-type": "application/json" },
        },
      );
    }) as typeof fetch;

    try {
      await ollamaChat(
        "Answer using only support actually available in this invocation.",
      );

      assert.equal(
        prompt.includes(POSITIVE_CONVERSATION_INSTRUCTION),
        false,
      );

      assert.match(
        prompt,
        /Allowed conversation support source = NONE/,
      );

      assert.match(
        prompt,
        /No prior conversation support source identifiers were supplied\. Do not return any conversation_turn entry in supportSourceReferences\./,
      );

      assert.match(
        prompt,
        /The current user message is not a prior conversation support source and must not be represented as conversation_turn provenance\./,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "nonempty history retains positive conversation-turn construction instruction",
  async () => {
    const originalFetch = globalThis.fetch;
    let prompt = "";

    globalThis.fetch = (async (_input, init) => {
      const body = JSON.parse(String(init?.body ?? "{}"));
      prompt = String(body.prompt ?? "");

      return new Response(
        JSON.stringify({
          response: JSON.stringify({
            reply: "The supplied prior turn supports this reply.",
            explanationStatus: "optional",
            selectedContextCandidatePositions: [],
            supportSourceReferences: [
              {
                type: "conversation_turn",
                sourceTurnId: "turn-source-1",
              },
            ],
            evidence: null,
            investigationLifecycle: null,
            packageSemantics: null,
            durableInterpretation: "The user requested bounded support provenance.",
          }),
        }),
        {
          status: 200,
          headers: { "content-type": "application/json" },
        },
      );
    }) as typeof fetch;

    try {
      await ollamaChat(
        "Use the supplied prior conversation support.",
        {
          history: [
            {
              sourceTurnId: "turn-source-1",
              userMessage: "Earlier user message",
              assistantReply: "Earlier assistant reply",
            },
          ],
        },
      );

      assert.equal(
        prompt.includes(POSITIVE_CONVERSATION_INSTRUCTION),
        true,
      );

      assert.match(
        prompt,
        /Allowed conversation support source = turn-source-1/,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
