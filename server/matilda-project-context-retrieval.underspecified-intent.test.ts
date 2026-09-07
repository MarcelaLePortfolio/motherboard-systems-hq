import assert from "node:assert/strict";
import test from "node:test";
import path from "node:path";

import {
  retrieveMatildaProjectContext,
} from "./matilda-project-context-retrieval";

const projectRootPath = path.resolve(
  import.meta.dirname,
  "..",
);

test(
  "underspecified project-change intent does not search project context before clarification",
  () => {
    const result = retrieveMatildaProjectContext({
      projectId: "hq",
      projectRootPath,
      message:
        "i want to make a small change to the frontend",
    });

    assert.equal(result.available, true);
    assert.equal(result.searched, false);
    assert.ok(result.queryTerms.includes("change"));
    assert.ok(result.queryTerms.includes("frontend"));
    assert.deepEqual(result.excerpts, []);
    assert.deepEqual(
      result.projectContextSegmentCandidates,
      [],
    );
    assert.equal(result.warning, null);
  },
);

test(
  "specific project-change intent still searches project context",
  () => {
    const result = retrieveMatildaProjectContext({
      projectId: "hq",
      projectRootPath,
      message:
        "change the frontend navigation label from Packages to Workspaces",
    });

    assert.equal(result.available, true);
    assert.equal(result.searched, true);
    assert.ok(result.queryTerms.includes("frontend"));
    assert.ok(result.queryTerms.includes("navigation"));
  },
);

test(
  "substantive project questions remain eligible for project retrieval",
  () => {
    const result = retrieveMatildaProjectContext({
      projectId: "hq",
      projectRootPath,
      message:
        "How does durable interpretation persistence work?",
    });

    assert.equal(result.available, true);
    assert.equal(result.searched, true);
    assert.ok(result.queryTerms.includes("durable"));
    assert.ok(result.queryTerms.includes("interpretation"));
  },
);
