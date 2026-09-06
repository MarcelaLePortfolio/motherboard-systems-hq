import assert from "node:assert/strict";
import test from "node:test";

import {
  retrieveMatildaProjectContext,
} from "./matilda-project-context-retrieval";

const ROOT =
  "/Users/marcela-dev/Projects/motherboard-systems-hq-clean";

const PACKAGES_REQUEST =
  "right now, i would just like to make some random tweaks. for example, first, i think i would like to remove the Packages tab from the sidebar, underneath the Workspace header.";

test("retrieval origin is preserved on every child candidate from the actual parent retrieval path", () => {
  const result = retrieveMatildaProjectContext({
    projectId: "hq",
    projectRootPath: ROOT,
    message: PACKAGES_REQUEST,
  });

  assert.equal(result.available, true);
  assert.equal(result.searched, true);
  assert.ok(
    result.projectContextSegmentCandidates.length > 0,
  );

  for (
    const candidate of
    result.projectContextSegmentCandidates
  ) {
    assert.ok(
      candidate.retrievalOrigin === "lexical" ||
        candidate.retrievalOrigin === "structural",
    );
  }

  const structural =
    result.projectContextSegmentCandidates.filter(
      (candidate) =>
        candidate.retrievalOrigin === "structural",
    );

  assert.equal(structural.length, 1);
  assert.equal(
    structural[0].parentRelativePath,
    "client/src/shell/NavigationRegion.tsx",
  );

  assert.match(
    structural[0].text,
    /activeWorkspace === "packages"/,
  );
  assert.match(
    structural[0].text,
    /onSelectWorkspace\s*\(\s*"packages"\s*\)/,
  );

  const lexical =
    result.projectContextSegmentCandidates.filter(
      (candidate) =>
        candidate.retrievalOrigin === "lexical",
    );

  assert.ok(lexical.length > 0);

  assert.equal(
    result.projectContextSegmentCandidates.length,
    lexical.length + structural.length,
  );
});

test("retrieval origin is provenance only and does not alter candidate ordering", () => {
  const result = retrieveMatildaProjectContext({
    projectId: "hq",
    projectRootPath: ROOT,
    message: PACKAGES_REQUEST,
  });

  const navigationIndex =
    result.projectContextSegmentCandidates.findIndex(
      (candidate) =>
        candidate.parentRelativePath ===
          "client/src/shell/NavigationRegion.tsx" &&
        candidate.retrievalOrigin === "structural",
    );

  const cssIndex =
    result.projectContextSegmentCandidates.findIndex(
      (candidate) =>
        candidate.parentRelativePath ===
        "client/src/packages/packages-workspace.css",
    );

  assert.equal(cssIndex, 0);
  assert.equal(navigationIndex, 5);
});
