import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const source = fs.readFileSync(
  new URL("./ollamaChat.ts", import.meta.url),
  "utf8",
);

test(
  "child candidate identity uses explicit named fields instead of source-style notation",
  () => {
    assert.match(
      source,
      /"Segment candidate:"/,
    );

    assert.match(
      source,
      /`relativePath = \$\{item\.relativePath\}`/,
    );

    assert.match(
      source,
      /`sourceStartLine = \$\{item\.sourceStartLine\}`/,
    );

    assert.match(
      source,
      /`sourceEndLine = \$\{item\.sourceEndLine\}`/,
    );

    assert.doesNotMatch(
      source,
      /`Segment source: \$\{item\.relativePath\}:\$\{item\.sourceStartLine\}-\$\{item\.sourceEndLine\}`/,
    );
  },
);

test(
  "parent support Source presentation remains unchanged",
  () => {
    assert.match(
      source,
      /`Source: \$\{item\.relativePath\}:\$\{item\.lineNumber\}`/,
    );
  },
);

test(
  "selectedContextSegments structured identity contract remains unchanged",
  () => {
    assert.match(
      source,
      /relativePath/,
    );

    assert.match(
      source,
      /sourceStartLine/,
    );

    assert.match(
      source,
      /sourceEndLine/,
    );
  },
);
