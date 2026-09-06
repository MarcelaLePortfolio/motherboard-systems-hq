import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

import { retrieveMatildaProjectContext } from "./matilda-project-context-retrieval";

const packagesRequest =
  "right now, i would just like to make some random tweaks. for example, first, i think i would like to remove the Packages tab from the sidebar, underneath the Workspace header.";

test(
  "structurally discovered Packages navigation candidate receives its complete bounded control unit",
  () => {
    const result = retrieveMatildaProjectContext({
      projectId: "hq",
      projectRootPath: process.cwd(),
      message: packagesRequest,
    });

    const navigationCandidates =
      result.projectContextSegmentCandidates.filter(
        (candidate) =>
          candidate.parentRelativePath ===
          "client/src/shell/NavigationRegion.tsx",
      );

    assert.equal(
      navigationCandidates.length,
      1,
      "expected exactly one NavigationRegion child candidate",
    );

    const candidate = navigationCandidates[0];

    assert.equal(candidate.sourceStartLine, 71);
    assert.equal(candidate.sourceEndLine, 83);

    assert.match(
      candidate.text,
      /activeWorkspace === "packages"/,
    );

    assert.match(
      candidate.text,
      /onSelectWorkspace\("packages"\)/,
    );

    assert.match(
      candidate.text,
      />\s*Packages\s*<\/button>/,
    );

    assert.ok(
      candidate.sourceEndLine -
        candidate.sourceStartLine +
        1 <=
        13,
      "structural-unit candidate must not exceed the 13-line ceiling",
    );
  },
);

test(
  "structural-unit expansion is restricted to structurally discovered candidates",
  () => {
    const source = fs.readFileSync(
      "server/matilda-project-context-retrieval.ts",
      "utf8",
    );

    assert.match(
      source,
      /const MAX_STRUCTURAL_EXCERPT_LINES = 13;/,
    );

    assert.match(
      source,
      /useStructuralUnitExcerpt\?: boolean/,
    );

    assert.match(
      source,
      /useStructuralUnitExcerpt: true/,
    );

    assert.match(
      source,
      /candidate\.useStructuralUnitExcerpt === true/,
    );

    assert.doesNotMatch(
      source,
      /semanticScore|semanticFilter|materiallyAffects|postModel/i,
    );
  },
);

test(
  "ordinary lexical retrieval retains the existing five-line default window",
  () => {
    const source = fs.readFileSync(
      "server/matilda-project-context-retrieval.ts",
      "utf8",
    );

    assert.match(
      source,
      /let start = Math\.max\(0, lineNumber - 3\);/,
    );

    assert.match(
      source,
      /let end = Math\.min\(lines\.length, lineNumber \+ 2\);/,
    );

    assert.match(
      source,
      /useStructuralUnitExcerpt = false/,
    );
  },
);
