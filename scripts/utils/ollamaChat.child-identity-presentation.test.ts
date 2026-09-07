import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const source = fs.readFileSync(
  new URL("./ollamaChat.ts", import.meta.url),
  "utf8",
);

test(
  "production child semantic-selection identity is invocation-local candidate position",
  () => {
    assert.match(
      source,
      /`candidatePosition = \$\{candidatePosition\}`/,
    );
    assert.match(
      source,
      /selectedContextCandidatePositions: \{/,
    );
    assert.match(
      source,
      /type: "integer"/,
    );
    assert.match(
      source,
      /minimum: 0/,
    );
  },
);

test(
  "runtime candidate retains structural identity and parent provenance for deterministic projection",
  () => {
    assert.match(source, /relativePath: string;/);
    assert.match(source, /sourceStartLine: number;/);
    assert.match(source, /sourceEndLine: number;/);
    assert.match(source, /parentRelativePath: string;/);
    assert.match(source, /parentLineNumber: number;/);

    assert.match(
      source,
      /relativePath: suppliedSegment\.relativePath/,
    );
    assert.match(
      source,
      /sourceStartLine: suppliedSegment\.sourceStartLine/,
    );
    assert.match(
      source,
      /sourceEndLine: suppliedSegment\.sourceEndLine/,
    );
  },
);

test(
  "runtime projects validated positions back to structural selected-context segments",
  () => {
    assert.match(
      source,
      /deduplicatedSelectedContextCandidatePositions\.map/,
    );
    assert.match(
      source,
      /const suppliedSegment =\s*suppliedSegmentCandidates\[position\]/,
    );
  },
);
