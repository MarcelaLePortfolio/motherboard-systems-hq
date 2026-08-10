import assert from "node:assert/strict";
import test from "node:test";
import fs from "node:fs";

const source = fs.readFileSync(
  "scripts/utils/ollamaChat.ts",
  "utf8",
);

test(
  "Investigation Lifecycle is a required nullable structured artifact",
  () => {
    assert.match(
      source,
      /"investigationLifecycle",/,
    );

    assert.match(
      source,
      /investigationLifecycle:\s*\{\s*anyOf:/s,
    );

    assert.match(
      source,
      /type:\s*"null"/,
    );

    assert.match(
      source,
      /structured response without investigation lifecycle/,
    );
  },
);

test(
  "Investigation Lifecycle uses the bounded event vocabulary",
  () => {
    for (const event of [
      "entered",
      "continued",
      "advanced",
      "resolved",
      "superseded",
      "abandoned",
    ]) {
      assert.match(
        source,
        new RegExp(`"${event}"`),
      );
    }
  },
);

test(
  "Investigation Lifecycle validates semantic identity and governing question",
  () => {
    assert.match(
      source,
      /without investigation identity/,
    );

    assert.match(
      source,
      /without governing question/,
    );
  },
);

test(
  "advanced and resolved require a lifecycle determination",
  () => {
    assert.match(
      source,
      /lifecycleEvent === "advanced"/,
    );

    assert.match(
      source,
      /lifecycleEvent === "resolved"/,
    );

    assert.match(
      source,
      /without required determination/,
    );
  },
);

test(
  "ordinary conversation is instructed to return null lifecycle",
  () => {
    assert.match(
      source,
      /Set investigationLifecycle to null when the current response does not semantically enter, continue, advance, resolve, supersede, or abandon an investigation\./,
    );
  },
);

test(
  "lifecycle identity is not derived from conversation storage identity",
  () => {
    assert.match(
      source,
      /Do not use conversation identifiers or interpretation-entry identifiers as investigationIdentity merely because those identifiers exist\./,
    );
  },
);
