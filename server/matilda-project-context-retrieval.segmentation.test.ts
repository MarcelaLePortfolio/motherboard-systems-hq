import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";

const source = fs.readFileSync(
  "server/matilda-project-context-retrieval.ts",
  "utf8",
);

test(
  "bounded excerpt retains pre-trim pre-truncation source lines internally",
  () => {
    assert.match(
      source,
      /boundedSourceLines:\s*string\[\]/,
    );

    assert.match(
      source,
      /const boundedSourceLines = lines\.slice\(start, end\)/,
    );

    assert.match(
      source,
      /boundedSourceLines,\s*\n\s*};/,
    );
  },
);

test(
  "deterministic segment candidate preserves exact source-range identity",
  () => {
    assert.match(
      source,
      /interface MatildaProjectContextSegmentCandidate/,
    );

    assert.match(
      source,
      /relativePath:\s*string/,
    );

    assert.match(
      source,
      /matchedLineNumber:\s*number/,
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
      /text:\s*string/,
    );
  },
);

test(
  "segmentation uses blank lines structurally without semantic filtering",
  () => {
    assert.match(
      source,
      /input\.boundedSourceLines\[index\]\.trim\(\) === ""/,
    );

    assert.match(
      source,
      /segmentLines\.join\("\\n"\)/,
    );

    assert.doesNotMatch(
      source,
      /segment.*relevan|segment.*material|semantic.*segment/i,
    );
  },
);

test(
  "segment ordering and exact line ranges derive from source order",
  () => {
    assert.match(
      source,
      /let index = 0;[\s\S]*index < input\.boundedSourceLines\.length;[\s\S]*index \+= 1/,
    );

    assert.match(
      source,
      /sourceStartLine:\s*[\s\S]*input\.sourceStartLine \+ segmentStartIndex/,
    );

    assert.match(
      source,
      /sourceEndLine:\s*[\s\S]*input\.sourceStartLine \+ exclusiveEndIndex - 1/,
    );
  },
);

test(
  "empty blank-line units are not emitted as segments",
  () => {
    assert.match(
      source,
      /if \(segmentStartIndex === null\) \{\s*return;\s*\}/,
    );
  },
);

test(
  "segmentation remains inert and public excerpt assembly is unchanged",
  () => {
    const assembly =
      source.match(
        /excerpts\.push\(\{[\s\S]*?authorityStatus:\s*"candidate_evidence_not_authority",[\s\S]*?\}\);/,
      )?.[0] ?? "";

    assert.notEqual(
      assembly,
      "",
      "public excerpt assembly was not found",
    );

    assert.match(
      assembly,
      /relativePath:\s*candidate\.relativePath/,
    );

    assert.match(
      assembly,
      /lineNumber:\s*candidate\.lineNumber/,
    );

    assert.match(
      assembly,
      /excerpt:\s*boundedExcerpt\.excerpt/,
    );

    assert.doesNotMatch(
      assembly,
      /segment|startLineNumber|endLineNumber|boundedSourceLines/,
    );
  },
);

test(
  "segmentation does not alter the public project-context excerpt contract",
  () => {
    const publicContract =
      source.match(
        /export interface MatildaProjectContextExcerpt\s*\{[\s\S]*?\n\}/,
      )?.[0] ?? "";

    assert.notEqual(
      publicContract,
      "",
      "MatildaProjectContextExcerpt contract was not found",
    );

    assert.doesNotMatch(
      publicContract,
      /segment|startLineNumber|endLineNumber|boundedSourceLines/,
    );
  },
);
