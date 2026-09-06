import assert from "node:assert/strict";
import test from "node:test";
import { retrieveMatildaProjectContext } from "./matilda-project-context-retrieval";

const packagesRequest =
  "right now, i would just like to make some random tweaks. for example, first, i think i would like to remove the Packages tab from the sidebar, underneath the Workspace header.";

test(
  "Packages request structurally retrieves the NavigationRegion source",
  () => {
    const result = retrieveMatildaProjectContext({
      projectId: "hq",
      projectRootPath: process.cwd(),
      message: packagesRequest,
    });

    const navigationExcerpt = result.excerpts.find(
      (excerpt) =>
        excerpt.relativePath ===
        "client/src/shell/NavigationRegion.tsx"
    );

    assert.ok(
      navigationExcerpt,
      "expected NavigationRegion.tsx through bounded structural provenance"
    );

    assert.equal(
      result.excerpts.length <= 6,
      true,
      "structural discovery must preserve MAX_MATCHES"
    );

    assert.equal(
      result.projectContextSegmentCandidates.some(
        (candidate) =>
          candidate.parentRelativePath ===
          "client/src/shell/NavigationRegion.tsx"
      ),
      true,
      "structurally discovered parent must produce normal deterministic child candidates"
    );
  }
);

test(
  "structural retrieval does not replace Matilda semantic admission",
  () => {
    const source = require("node:fs").readFileSync(
      "server/matilda-project-context-retrieval.ts",
      "utf8"
    );

    assert.match(
      source,
      /discoverBoundedStructuralProjectContextCandidate/
    );

    assert.doesNotMatch(
      source,
      /semanticScore|semanticFilter|materiallyAffects|postModel/
    );
  }
);
