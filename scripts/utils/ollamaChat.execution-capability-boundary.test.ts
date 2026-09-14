import assert from "node:assert/strict";
import test from "node:test";

import { ollamaChat } from "./ollamaChat";

test(
  "ollamaChat presents the bounded non-execution capability fact in the single semantic invocation",
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
              "I can assess the supplied evidence, but I cannot perform the runtime verification from this conversation workflow.",
            explanationStatus: "optional",
            selectedContextCandidatePositions: [],
            supportSourceReferences: [],
            evidence: null,
            durableInterpretation:
              "The user requested runtime verification that requires an execution-capable surface.",
          }),
        }),
      } as Response;
    }) as typeof globalThis.fetch;

    try {
      await ollamaChat(
        "Please complete the underlying runtime verification.",
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
        /Current Matilda Chat capability boundary:/,
      );

      assert.match(
        prompt,
        /execution_authorized = false/,
      );

      assert.match(
        prompt,
        /cannot itself execute browser validation, repository\/runtime verification, code changes, shell commands, deployments, or other external actions/,
      );

      assert.match(
        prompt,
        /Do not claim that you personally performed or completed any action this workflow cannot execute/,
      );

      assert.match(
        prompt,
        /distinguish what can be concluded from supplied evidence from what still requires an execution-capable surface/,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "ollamaChat does not invent the capability boundary when none is supplied",
  async () => {
    const originalFetch = globalThis.fetch;
    let requestBody: Record<string, unknown> | null = null;

    globalThis.fetch = (async (
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
            investigationLifecycle: null,
            packageSemantics: null,
            reply: "Current response.",
            explanationStatus: "optional",
            selectedContextCandidatePositions: [],
            supportSourceReferences: [],
            evidence: null,
            durableInterpretation:
              "No durable user semantics were established in this turn.",
          }),
        }),
      } as Response;
    }) as typeof globalThis.fetch;

    try {
      await ollamaChat("Hello.");

      const prompt = String(
        requestBody?.prompt ?? "",
      );

      assert.equal(
        prompt.includes(
          "Current Matilda Chat capability boundary:",
        ),
        false,
      );

      assert.equal(
        prompt.includes(
          "execution_authorized = false",
        ),
        false,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
