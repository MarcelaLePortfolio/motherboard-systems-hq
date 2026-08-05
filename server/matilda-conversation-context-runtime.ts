import type {
  MatildaConversationTurn,
} from "../db/matilda-conversation-runtime";
import type {
  MatildaProjectContextRetrievalResult,
} from "./matilda-project-context-retrieval";
import {
  assembleMatildaConversationHistoryContext,
  type MatildaConversationHistoryContextTurn,
} from "./matilda-conversation-history-context";

export interface ComposeMatildaConversationContextInput {
  turns: MatildaConversationTurn[];
  projectContextRetrieval: MatildaProjectContextRetrievalResult;
}

export interface MatildaConversationContext {
  history: MatildaConversationHistoryContextTurn[];
  projectContextExcerpts:
    MatildaProjectContextRetrievalResult["excerpts"];
  projectContextWarning: string | null;
}

export function composeMatildaConversationContext(
  input: ComposeMatildaConversationContextInput,
): MatildaConversationContext {
  return {
    history: assembleMatildaConversationHistoryContext(
      input.turns,
    ),
    projectContextExcerpts:
      input.projectContextRetrieval.excerpts,
    projectContextWarning:
      input.projectContextRetrieval.warning,
  };
}
