import type {
  MatildaConversationTurn,
} from "../db/matilda-conversation-runtime";
import type {
  OllamaChatHistoryTurn,
} from "../scripts/utils/ollamaChat";

export function assembleMatildaConversationHistoryContext(
  turns: MatildaConversationTurn[],
): OllamaChatHistoryTurn[] {
  return turns.map((turn) => ({
    userMessage: turn.user_message,
    assistantReply: turn.assistant_reply,
  }));
}
