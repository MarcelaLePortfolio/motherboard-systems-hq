import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";

const source = fs.readFileSync(
  "server/matilda-project-context-retrieval.ts",
  "utf8",
);

test(
  "bounded excerpt reader records exact source-range metadata internally",
  () => {
    assert.match(
      source,
      /interface MatildaBoundedExcerptReadResult/,
    );

    assert.match(
      source,
      /sourceStartLine:\s*number/,
    );

    assert.match(
      source,
      /sourceEndLine:\s*number/,
    );

    assert.match(
      source,
      /excerptTruncated:\s*boolean/,
    );

    assert.match(
      source,
      /sourceStartLine:\s*start \+ 1/,
    );

    assert.match(
      source,
      /sourceEndLine:\s*end/,
    );
  },
);

test(
  "truncation metadata derives from the existing excerpt character cap",
  () => {
    assert.match(
      source,
      /excerpt:\s*boundedSource\.slice\(0,\s*MAX_EXCERPT_CHARACTERS\)/,
    );

    assert.match(
      source,
      /boundedSource\.length\s*>\s*MAX_EXCERPT_CHARACTERS/,
    );
  },
);

test(
  "range metadata does not alter the public project-context excerpt contract",
  () => {
    const publicContract =
      source.match(
        /export interface MatildaProjectContextExcerpt\s*\{[\s\S]*?\n\}/,
      )?.[0] ?? "";

    assert.notEqual(
      publicContract,
      "",
      "MatildaProjectContextExcerpt contract was not found.",
    );

    assert.doesNotMatch(
      publicContract,
      /sourceStartLine|sourceEndLine|excerptTruncated|metadata/,
    );
  },
);

test(
  "retrieval continues to publish the existing excerpt identity and text",
  () => {
    assert.match(
      source,
      /relativePath:\s*candidate\.relativePath/,
    );

    assert.match(
      source,
      /lineNumber:\s*candidate\.lineNumber/,
    );

    assert.match(
      source,
      /excerpt:\s*boundedExcerpt\.excerpt/,
    );

    assert.match(
      source,
      /provenance:\s*"git_tracked_project_file"/,
    );

    assert.match(
      source,
      /authorityStatus:\s*"candidate_evidence_not_authority"/,
    );
  },
);
