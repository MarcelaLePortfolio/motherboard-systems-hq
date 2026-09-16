import assert from "node:assert/strict";
import test from "node:test";

import {
  readAtlasPreExecutionRoute,
} from "./preexecution";

test(
  "pre-execution route requires explicit project scope",
  () => {
    assert.throws(
      () =>
        readAtlasPreExecutionRoute({
          projectId: "   ",
          conversationId: "conversation-1",
        }),
      /projectId is required/,
    );
  },
);

test(
  "pre-execution route requires explicit conversation scope",
  () => {
    assert.throws(
      () =>
        readAtlasPreExecutionRoute({
          projectId: "hq",
          conversationId: "   ",
        }),
      /conversationId is required/,
    );
  },
);

test(
  "pre-execution route returns valid empty structural result",
  () => {
    const result = readAtlasPreExecutionRoute({
      projectId: "hq",
      conversationId:
        "__atlas_preexecution_route_empty_fixture__",
      databasePath: "db/main.db",
    });

    assert.equal(result.projectId, "hq");
    assert.deepEqual(result.observations, []);
    assert.deepEqual(result.lineageSequences, []);
  },
);
