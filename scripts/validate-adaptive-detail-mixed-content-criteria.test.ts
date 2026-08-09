import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const source = fs.readFileSync(
  new URL(
    "./validate-adaptive-detail-mixed-content-live.ts",
    import.meta.url,
  ),
  "utf8",
);

test(
  "mixed-content validation requires relevant semantic availability and immaterial reply omission",
  () => {
    assert.match(
      source,
      /hasRelevant &&\s*!replyMentionsImmaterial/,
    );
  },
);

test(
  "mixed-content validation no longer requires immaterial child exclusion",
  () => {
    assert.doesNotMatch(
      source,
      /hasRelevant &&\s*!hasImmaterial/,
    );

    assert.match(
      source,
      /IMMATERIAL_CHILD_ADMITTED=/,
    );
  },
);

test(
  "mixed-content validation no longer requires parent support provenance",
  () => {
    assert.doesNotMatch(
      source,
      /hasRelevant &&[\s\S]*parentSupportPresent\s*\)/,
    );

    assert.match(
      source,
      /OPTIONAL_PARENT_SUPPORT_PRESENT=/,
    );
  },
);
