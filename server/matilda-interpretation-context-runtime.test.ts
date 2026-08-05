import test from "node:test";
import assert from "node:assert/strict";

import type {
  MatildaConversationHistoryContextTurn,
} from "./matilda-conversation-history-context";
import {
  buildInterpretationContext,
} from "./matilda-interpretation-context-runtime";

function createHistoryTurn(
  overrides:
    Partial<MatildaConversationHistoryContextTurn> = {},
): MatildaConversationHistoryContextTurn {
  return {
    sourceTurnId: "turn-1",
    interpretationEntryId: "iel-1",
    userMessage: "User",
    assistantReply: "Assistant",
    userMessageAuthority: "user_statement",
    assistantReplyAuthority: "assistant_claim",
    contaminationStatus: "unassessed",
    ...overrides,
  };
}

test(
  "builds interpretation context without modifying history",
  () => {
    const history = [createHistoryTurn()];
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

test(
  "resolves current interpretation lifecycle state",
  () => {
    const context =
      buildInterpretationContext(
        [createHistoryTurn()],
        [
          {
            entry_id: "iel-1",
            supersession_status: "current",
          },
        ],
      );

    assert.equal(
      context[0].supersessionStatus,
      "current",
    );
  },
);

test(
  "resolves superseded interpretation lifecycle state",
  () => {
    const context =
      buildInterpretationContext(
        [createHistoryTurn()],
        [
          {
            entry_id: "iel-1",
            supersession_status: "superseded",
          },
        ],
      );

    assert.equal(
      context[0].supersessionStatus,
      "superseded",
    );
  },
);

test(
  "fails closed for unsupported lifecycle values",
  () => {
    const context =
      buildInterpretationContext(
        [createHistoryTurn()],
        [
          {
            entry_id: "iel-1",
            supersession_status: "archived",
          },
        ],
      );

    assert.equal(
      context[0].supersessionStatus,
      "unknown",
    );
  },
);

test(
  "matches lifecycle records by interpretation entry identity",
  () => {
    const context =
      buildInterpretationContext(
        [
          createHistoryTurn({
            sourceTurnId: "turn-1",
            interpretationEntryId: "iel-1",
          }),
          createHistoryTurn({
            sourceTurnId: "turn-2",
            interpretationEntryId: "iel-2",
          }),
        ],
        [
          {
            entry_id: "iel-2",
            supersession_status: "superseded",
          },
          {
            entry_id: "iel-1",
            supersession_status: "current",
          },
        ],
      );

    assert.deepEqual(
      context.map((entry) => ({
        interpretationEntryId:
          entry.interpretationEntryId,
        supersessionStatus:
          entry.supersessionStatus,
      })),
      [
        {
          interpretationEntryId: "iel-1",
          supersessionStatus: "current",
        },
        {
          interpretationEntryId: "iel-2",
          supersessionStatus: "superseded",
        },
      ],
    );
  },
);
