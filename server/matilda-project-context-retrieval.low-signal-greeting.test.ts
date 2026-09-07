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
  '"hey matilda" is treated as low-signal chatter and does not search project context',
  () => {
    const result = retrieveMatildaProjectContext({
      projectId: "hq",
      projectRootPath,
      message: "hey matilda",
    });

    assert.equal(result.available, true);
    assert.equal(result.searched, false);
    assert.deepEqual(result.queryTerms, []);
    assert.deepEqual(result.excerpts, []);
    assert.deepEqual(
      result.projectContextSegmentCandidates,
      [],
    );
    assert.equal(result.warning, null);
  },
);

test(
  "meaningful project language still triggers normal retrieval",
  () => {
    const result = retrieveMatildaProjectContext({
      projectId: "hq",
      projectRootPath,
      message:
        "show me the durable interpretation architecture",
    });

    assert.equal(result.available, true);
    assert.equal(result.searched, true);
    assert.ok(
      result.queryTerms.includes("durable"),
    );
    assert.ok(
      result.queryTerms.includes("interpretation"),
    );
  },
);
