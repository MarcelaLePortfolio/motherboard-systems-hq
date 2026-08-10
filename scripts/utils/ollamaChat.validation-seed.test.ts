import assert from "node:assert/strict";
import test from "node:test";

import { ollamaChat } from "./ollamaChat";

const validResponse = JSON.stringify({
          investigationLifecycle: null,
  reply: "Answer.",
  explanationStatus: "optional",
  selectedContextSegments: [],
  supportSourceReferences: [],
  evidence: null,
  evidenceSufficient: false,
  durableInterpretation: "Interpretation.",
});

test(
  "normal invocation omits validation-only generation options",
  async () => {
    const originalFetch = globalThis.fetch;
    let invocationCount = 0;
    let capturedBody: Record<string, unknown> | null = null;

    globalThis.fetch = (async (
      _input: string | URL | Request,
      init?: RequestInit,
    ) => {
      invocationCount += 1;
      capturedBody = JSON.parse(String(init?.body));

      return new Response(
        JSON.stringify({
          investigationLifecycle: null, response: validResponse }),
        {
          status: 200,
          headers: {
            "Content-Type": "application/json",
          },
        },
      );
    }) as typeof fetch;

    try {
      await ollamaChat("Question.");

      assert.equal(invocationCount, 1);
      assert.ok(capturedBody);
      assert.equal(
        Object.prototype.hasOwnProperty.call(
          capturedBody,
          "options",
        ),
        false,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "validation seed reaches the existing single Ollama invocation",
  async () => {
    const originalFetch = globalThis.fetch;
    let invocationCount = 0;
    let capturedBody: Record<string, unknown> | null = null;

    globalThis.fetch = (async (
      _input: string | URL | Request,
      init?: RequestInit,
    ) => {
      invocationCount += 1;
      capturedBody = JSON.parse(String(init?.body));

      return new Response(
        JSON.stringify({
          investigationLifecycle: null, response: validResponse }),
        {
          status: 200,
          headers: {
            "Content-Type": "application/json",
          },
        },
      );
    }) as typeof fetch;

    try {
      await ollamaChat("Question.", {
        validationGenerationSeed: 424242,
      });

      assert.equal(invocationCount, 1);
      assert.ok(capturedBody);
      assert.deepEqual(
        capturedBody.options,
        {
          seed: 424242,
        },
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
