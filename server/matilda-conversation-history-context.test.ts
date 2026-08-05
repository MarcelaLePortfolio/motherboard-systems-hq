import test from "node:test";
import assert from "node:assert/strict";

import type {
  MatildaConversationTurn,
} from "../db/matilda-conversation-runtime";
import {
  assembleMatildaConversationHistoryContext,
} from "./matilda-conversation-history-context";

function createTurn(
  overrides: Partial<MatildaConversationTurn> = {},
): MatildaConversationTurn {
  return {
    turn_id: "turn-1",
    project_id: "hq",
    conversation_id: "conversation-1",
    user_message: "User message.",
    assistant_reply: "Assistant reply.",
    interpretation_entry_id: "iel-1",
    project_context_evidence_trace_json: null,
    created_at: "2026-08-05T00:00:00.000Z",
    ...overrides,
  };
}

test(
  "assembles conversation history without changing content or order",
  () => {
    const turns: MatildaConversationTurn[] = [
      createTurn({
        turn_id: "turn-1",
        user_message: "First user message.",
        assistant_reply: "First assistant reply.",
        interpretation_entry_id: "iel-1",
        created_at: "2026-08-05T00:00:00.000Z",
      }),
      createTurn({
        turn_id: "turn-2",
        user_message: "Second user message.",
        assistant_reply: "Second assistant reply.",
        interpretation_entry_id: "iel-2",
        created_at: "2026-08-05T00:01:00.000Z",
      }),
    ];

    assert.deepEqual(
      assembleMatildaConversationHistoryContext(turns),
      [
        {
          sourceTurnId: "turn-1",
          userMessage: "First user message.",
          userMessageAuthority: "user_statement",
          assistantReply: "First assistant reply.",
          assistantReplyAuthority: "assistant_claim",
        },
        {
          sourceTurnId: "turn-2",
          userMessage: "Second user message.",
          userMessageAuthority: "user_statement",
          assistantReply: "Second assistant reply.",
          assistantReplyAuthority: "assistant_claim",
        },
      ],
    );
  },
);

test(
  "classifies user statements separately from assistant claims",
  () => {
    const [contextTurn] =
      assembleMatildaConversationHistoryContext([
        createTurn(),
      ]);

    assert.equal(
      contextTurn.userMessageAuthority,
      "user_statement",
    );
    assert.equal(
      contextTurn.assistantReplyAuthority,
      "assistant_claim",
    );
    assert.notEqual(
      contextTurn.userMessageAuthority,
      contextTurn.assistantReplyAuthority,
    );
  },
);

test(
  "preserves the persisted source turn identifier",
  () => {
    const [contextTurn] =
      assembleMatildaConversationHistoryContext([
        createTurn({
          turn_id: "turn-authority-source",
        }),
      ]);

    assert.equal(
      contextTurn.sourceTurnId,
      "turn-authority-source",
    );
  },
);

test(
  "does not mutate persisted conversation turns",
  () => {
    const turns = [createTurn()];
    const before = structuredClone(turns);

    assembleMatildaConversationHistoryContext(turns);

    assert.deepEqual(turns, before);
  },
);
