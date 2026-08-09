import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const source = fs.readFileSync(
  "scripts/validate-source-excerpt-first-live.ts",
  "utf8",
);

test(
  "Source-Excerpt live validator supplies current child-candidate contract",
  () => {
    assert.match(
      source,
      /projectContextSegmentCandidates:\s*\[/,
    );

    assert.match(
      source,
      /parentRelativePath:\s*relativePath/,
    );

    assert.match(
      source,
      /parentLineNumber/,
    );

    assert.match(
      source,
      /sourceStartLine:\s*parentLineNumber/,
    );

    assert.match(
      source,
      /sourceEndLine:\s*parentLineNumber/,
    );

    assert.match(
      source,
      /text:\s*suppliedExcerpt/,
    );
  },
);

test(
  "Source-Excerpt live validator preserves parent Source identity",
  () => {
    assert.match(
      source,
      /"server\/matilda-chat-workflow\.ts"/,
    );

    assert.match(
      source,
      /const parentLineNumber = 155/,
    );
  },
);

test(
  "Source-Excerpt live validator isolates repository evidence without competing conversation support",
  () => {
    assert.doesNotMatch(
      source,
      /\bhistory\s*:/,
    );

    assert.doesNotMatch(
      source,
      /turn-source-excerpt-live-validation/,
    );

    assert.match(
      source,
      /projectContextExcerpts:\s*\[/,
    );
  },
);
