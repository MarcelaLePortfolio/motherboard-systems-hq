import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const source = fs.readFileSync(
  new URL(
    "./matilda-project-context-retrieval.ts",
    import.meta.url,
  ),
  "utf8",
);

test("segment candidate contract preserves deterministic parent excerpt identity", () => {
  const contract =
    source.match(
      /export interface MatildaProjectContextSegmentCandidate \{[\s\S]*?\n\}/,
    )?.[0] ?? "";

  assert.match(
    contract,
    /parentRelativePath:\s*string/,
  );

  assert.match(
    contract,
    /parentLineNumber:\s*number/,
  );

  assert.match(
    contract,
    /sourceStartLine:\s*number/,
  );

  assert.match(
    contract,
    /sourceEndLine:\s*number/,
  );
});

test("segment construction derives parent identity from the admitted parent excerpt candidate", () => {
  const construction =
    source.match(
      /segments\.push\(\{[\s\S]*?text:\s*segmentLines\.join\("\\n"\),[\s\S]*?\}\);/,
    )?.[0] ?? "";

  assert.match(
    construction,
    /parentRelativePath:\s*input\.relativePath/,
  );

  assert.match(
    construction,
    /parentLineNumber:\s*input\.matchedLineNumber/,
  );
});

test("parent identity does not replace exact child source-range identity", () => {
  const construction =
    source.match(
      /segments\.push\(\{[\s\S]*?text:\s*segmentLines\.join\("\\n"\),[\s\S]*?\}\);/,
    )?.[0] ?? "";

  assert.match(
    construction,
    /sourceStartLine:[\s\S]*?input\.sourceStartLine \+ segmentStartIndex/,
  );

  assert.match(
    construction,
    /sourceEndLine:[\s\S]*?input\.sourceStartLine \+ exclusiveEndIndex - 1/,
  );
});
