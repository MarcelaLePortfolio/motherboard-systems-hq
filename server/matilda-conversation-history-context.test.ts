import test from "node:test";
import assert from "node:assert/strict";

import type {
  MatildaConversationTurn,
} from "../db/matilda-conversation-runtime";
import {
  assembleMatildaConversationHistoryContext,
} from "./matilda-conversation-history-context";

test(
  "assembles conversation history without changing content or order",
  () => {
    const turns: MatildaConversationTurn[] = [
      {
        turn_id: "turn-1",
        project_id: "hq",
        conversation_id: "conversation-1",
        user_message: "First user message.",
        assistant_reply: "First assistant reply.",
        interpretation_entry_id: "iel-1",
        project_context_evidence_trace_json: null,
        created_at: "2026-08-05T00:00:00.000Z",
      },
      {
        turn_id: "turn-2",
        project_id: "hq",
        conversation_id: "conversation-1",
        user_message: "Second user message.",
        assistant_reply: "Second assistant reply.",
        interpretation_entry_id: "iel-2",
        project_context_evidence_trace_json: null,
        created_at: "2026-08-05T00:01:00.000Z",
      },
    ];

    assert.deepEqual(
      assembleMatildaConversationHistoryContext(turns),
      [
        {
          userMessage: "First user message.",
          assistantReply: "First assistant reply.",
        },
        {
          userMessage: "Second user message.",
          assistantReply: "Second assistant reply.",
        },
      ],
    );
  },
);

test(
  "does not mutate persisted conversation turns",
  () => {
    const turns: MatildaConversationTurn[] = [
      {
        turn_id: "turn-1",
        project_id: "hq",
        conversation_id: "conversation-1",
        user_message: "User message.",
        assistant_reply: "Assistant reply.",
        interpretation_entry_id: "iel-1",
        project_context_evidence_trace_json: null,
        created_at: "2026-08-05T00:00:00.000Z",
      },
    ];

    const before = structuredClone(turns);

    assembleMatildaConversationHistoryContext(turns);

    assert.deepEqual(turns, before);
  },
);
