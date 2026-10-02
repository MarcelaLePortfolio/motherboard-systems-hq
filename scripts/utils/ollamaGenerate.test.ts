import assert from "node:assert/strict";
import test from "node:test";

import {
  ollamaGenerate,
} from "./ollamaGenerate.ts";

test("generic Ollama transport sends generation request without domain semantics", async () => {
  let capturedUrl = "";
  let capturedBody: Record<string, unknown> | null = null;

  const result = await ollamaGenerate({
    base_url: "http://ollama.test/",
    model: "test-model",
    timeout_ms: 1000,
    prompt: "Return structured evidence.",
    format: {
      type: "object",
    },
    options: {
      temperature: 0,
    },
    fetch_impl: async (input, init) => {
      capturedUrl = String(input);
      capturedBody = JSON.parse(String(init?.body));

      return new Response(
        JSON.stringify({
          response: '{"status":"ok"}',
        }),
        {
          status: 200,
          headers: {
            "content-type": "application/json",
          },
        },
      );
    },
  });

  assert.equal(capturedUrl, "http://ollama.test/api/generate");
  assert.deepEqual(capturedBody, {
    model: "test-model",
    prompt: "Return structured evidence.",
    stream: false,
    format: {
      type: "object",
    },
    options: {
      temperature: 0,
    },
  });
  assert.deepEqual(result, {
    response: '{"status":"ok"}',
  });
});

test("generic Ollama transport fails closed on non-success HTTP response", async () => {
  await assert.rejects(
    () =>
      ollamaGenerate({
        prompt: "test",
        timeout_ms: 1000,
        fetch_impl: async () =>
          new Response("model unavailable", {
            status: 503,
          }),
      }),
    /HTTP 503.*model unavailable/i,
  );
});

test("generic Ollama transport fails closed on empty model response", async () => {
  await assert.rejects(
    () =>
      ollamaGenerate({
        prompt: "test",
        timeout_ms: 1000,
        fetch_impl: async () =>
          new Response(
            JSON.stringify({
              response: "   ",
            }),
            {
              status: 200,
              headers: {
                "content-type": "application/json",
              },
            },
          ),
      }),
    /empty or invalid response/i,
  );
});
