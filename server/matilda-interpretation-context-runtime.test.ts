import test from "node:test";
import assert from "node:assert/strict";

import {
  buildInterpretationContext,
} from "./matilda-interpretation-context-runtime";

test(
  "builds interpretation context without modifying history",
  () => {
    const history = [
      {
        sourceTurnId: "turn-1",
        interpretationEntryId: "iel-1",
        userMessage: "User",
        assistantReply: "Assistant",
        userMessageAuthority: "user_statement" as const,
        assistantReplyAuthority: "assistant_claim" as const,
        contaminationStatus: "unassessed" as const,
      },
    ];

    const before = structuredClone(history);

    const context =
      buildInterpretationContext(history);

    assert.deepEqual(history, before);

    assert.deepEqual(context, [
      {
        interpretationEntryId: "iel-1",
        sourceTurnId: "turn-1",
        supersessionStatus: "unknown",
        contaminationStatus: "unassessed",
      },
    ]);
  },
);
