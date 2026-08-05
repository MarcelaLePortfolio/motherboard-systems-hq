import test from "node:test";
import assert from "node:assert/strict";

import { ollamaChat } from "./ollamaChat";

test(
  "ollamaChat returns distinct structured artifacts from one invocation",
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
            reply: "We can proceed carefully.",
            durableInterpretation:
              "User authorizes careful continuation of the active corridor.",
          }),
        }),
      } as Response;
    };

    try {
      const result = await ollamaChat(
        "Continue carefully.",
      );

      assert.equal(invocationCount, 1);
      assert.equal(
        result.reply,
        "We can proceed carefully.",
      );
      assert.equal(
        result.durableInterpretation,
        "User authorizes careful continuation of the active corridor.",
      );
      assert.notEqual(
        result.reply,
        result.durableInterpretation,
      );

      assert.equal(requestBody?.stream, false);
      assert.equal(
        typeof requestBody?.format,
        "object",
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "ollamaChat serializes supplied conversation history unchanged and in order",
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
            reply: "Current response.",
            durableInterpretation:
              "Current durable interpretation.",
          }),
        }),
      } as Response;
    };

    try {
      await ollamaChat(
        "Current question.",
        {
          history: [
            {
              userMessage: "First user message.",
              assistantReply: "First assistant reply.",
            },
            {
              userMessage: "Second user message.",
              assistantReply: "Second assistant reply.",
            },
          ],
        },
      );

      const prompt = String(requestBody?.prompt ?? "");

      const firstUserIndex =
        prompt.indexOf("User: First user message.");
      const firstAssistantIndex =
        prompt.indexOf("Matilda: First assistant reply.");
      const secondUserIndex =
        prompt.indexOf("User: Second user message.");
      const secondAssistantIndex =
        prompt.indexOf("Matilda: Second assistant reply.");
      const currentUserIndex =
        prompt.lastIndexOf("User: Current question.");

      assert.ok(firstUserIndex >= 0);
      assert.ok(firstAssistantIndex > firstUserIndex);
      assert.ok(secondUserIndex > firstAssistantIndex);
      assert.ok(secondAssistantIndex > secondUserIndex);
      assert.ok(currentUserIndex > secondAssistantIndex);
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "ollamaChat fails closed when structured JSON is malformed",
  async () => {
    const originalFetch = globalThis.fetch;

    globalThis.fetch = async () =>
      ({
        ok: true,
        status: 200,
        statusText: "OK",
        json: async () => ({
          response: "not valid json",
        }),
      }) as Response;

    try {
      await assert.rejects(
        () => ollamaChat("Hello."),
        /malformed structured response JSON/,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "ollamaChat fails closed when durable interpretation is missing",
  async () => {
    const originalFetch = globalThis.fetch;

    globalThis.fetch = async () =>
      ({
        ok: true,
        status: 200,
        statusText: "OK",
        json: async () => ({
          response: JSON.stringify({
            reply: "Hello.",
          }),
        }),
      }) as Response;

    try {
      await assert.rejects(
        () => ollamaChat("Hello."),
        /empty durable interpretation/,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
