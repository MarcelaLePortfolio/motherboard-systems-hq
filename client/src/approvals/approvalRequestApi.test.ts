import assert from "node:assert/strict";
import test from "node:test";

import type {
  ApprovalRequestCollection,
} from "./approvalRequestApi";

test("ApprovalRequestCollection typing", () => {
  const collection: ApprovalRequestCollection = {
    project_id: "hq",
    requests: [],
  };

  assert.equal(collection.project_id, "hq");
  assert.deepEqual(collection.requests, []);
});
