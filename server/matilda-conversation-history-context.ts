import type {
  MatildaConversationTurn,
} from "../db/matilda-conversation-runtime";
import type {
  OllamaChatHistoryTurn,
} from "../scripts/utils/ollamaChat";

export type MatildaConversationHistoryAuthority =
  | "user_statement"
  | "assistant_claim";

export type MatildaConversationHistoryContaminationStatus =
  | "unassessed";

export interface MatildaConversationHistoryContextTurn
  extends OllamaChatHistoryTurn {
  sourceTurnId: string;
  userMessageAuthority: "user_statement";
  assistantReplyAuthority: "assistant_claim";
  contaminationStatus: "unassessed";
}

export function assembleMatildaConversationHistoryContext(
  turns: MatildaConversationTurn[],
): MatildaConversationHistoryContextTurn[] {
  return turns.map((turn) => ({
    sourceTurnId: turn.turn_id,
    userMessage: turn.user_message,
    userMessageAuthority: "user_statement",
    assistantReply: turn.assistant_reply,
    assistantReplyAuthority: "assistant_claim",
    contaminationStatus: "unassessed",
  }));
}
