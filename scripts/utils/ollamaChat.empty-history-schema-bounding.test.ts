import assert from "node:assert/strict";
import test from "node:test";
import fs from "node:fs";

const source = fs.readFileSync(
  new URL("./ollamaChat.ts", import.meta.url),
  "utf8",
);

test("empty-history output schema is invocation-relative", () => {
  assert.match(
    source,
    /function buildOllamaChatOutputSchema\([\s\S]*allowedConversationSupportSourceIds: readonly string\[\]/,
  );

  assert.match(
    source,
    /allowedConversationSupportSourceIds\.length === 0/,
  );

  assert.match(
    source,
    /enum: \["project_context_excerpt"\]/,
  );

  assert.match(
    source,
    /format: buildOllamaChatOutputSchema\([\s\S]*allowedConversationSupportSourceIds/,
  );
});

test("schema bounding does not remove conversation support globally", () => {
  assert.match(
    source,
    /BASE_OLLAMA_CHAT_OUTPUT_SCHEMA[\s\S]*"conversation_turn"/,
  );

  assert.doesNotMatch(
    source,
    /BASE_OLLAMA_CHAT_OUTPUT_SCHEMA[\s\S]*enum: \["project_context_excerpt"\][\s\S]*required:/,
  );
});

test("existing fail-closed validation remains present", () => {
  assert.match(
    source,
    /conversation support reference that was not supplied/,
  );
});
