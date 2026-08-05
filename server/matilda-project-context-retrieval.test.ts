import test from "node:test";
import assert from "node:assert/strict";

import { retrieveMatildaProjectContext } from "./matilda-project-context-retrieval";

const projectRootPath = process.cwd();

test("generic testing chatter does not trigger project retrieval", () => {
  const result = retrieveMatildaProjectContext({
    projectId: "hq",
    projectRootPath,
    message: "still testing",
  });

  assert.equal(result.available, true);
  assert.equal(result.searched, false);
  assert.deepEqual(result.queryTerms, []);
  assert.deepEqual(result.excerpts, []);
  assert.equal(result.warning, null);
});

test("substantive project questions still trigger retrieval", () => {
  const result = retrieveMatildaProjectContext({
    projectId: "hq",
    projectRootPath,
    message: "How does durable interpretation persistence work?",
  });

  assert.equal(result.available, true);
  assert.equal(result.searched, true);
  assert.ok(result.queryTerms.includes("durable"));
  assert.ok(result.queryTerms.includes("interpretation"));
  assert.ok(result.excerpts.length > 0);
});
