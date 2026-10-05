import assert from "node:assert/strict";
import test from "node:test";
import fs from "node:fs";

const source = fs.readFileSync(
  "scripts/utils/ollamaChat.ts",
  "utf8",
);

test("empty-history presentation requires empty support references", () => {
  assert.match(
    source,
    /No prior conversation support source identifiers were supplied\.[\s\S]*Return an empty supportSourceReferences array\./,
  );
});

test("conversation-turn construction instruction is conditional on supplied history", () => {
  assert.match(
    source,
    /const conversationSupportInstruction =[\s\S]*allowedConversationSupportSourceIds\.length > 0[\s\S]*For conversation support, use type conversation_turn/,
  );
});

test("nonempty history retains exact conversation support identity contract", () => {
  assert.match(
    source,
    /For type conversation_turn, use only one of the exact allowed conversation support source identifiers listed above\./,
  );
});
