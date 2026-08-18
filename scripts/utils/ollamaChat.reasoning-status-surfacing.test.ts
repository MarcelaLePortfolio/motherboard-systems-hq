import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

const source = readFileSync(
  new URL("./ollamaChat.ts", import.meta.url),
  "utf8",
);

test(
  "reasoning status governs reply detail without becoming a visible label",
  () => {
    assert.match(
      source,
      /Use explanationStatus to govern the amount of supporting reasoning in reply without exposing explanationStatus itself as a user-visible label\./,
    );

    assert.match(
      source,
      /When explanationStatus is optional, keep reply concise and include only the supporting reasoning needed for the immediate interaction\./,
    );

    assert.match(
      source,
      /When explanationStatus is recommended, keep the concise answer first, then include enough supporting reasoning to preserve any material architectural boundary, implementation boundary, uncertainty, tradeoff, or evidence interpretation that could change the user's next engineering decision\./,
    );

    assert.match(
      source,
      /Do not add a visible Reasoning Status, Optional, or Recommended label merely because explanationStatus is present\./,
    );
  },
);
