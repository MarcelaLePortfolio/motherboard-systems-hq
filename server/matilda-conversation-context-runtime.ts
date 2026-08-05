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
import {
  buildInterpretationContext,
  type MatildaInterpretationContext,
  type MatildaInterpretationLifecycleEntry,
} from "./matilda-interpretation-context-runtime";
import {
  evaluateMatildaHistoryAuthority,
  type MatildaEvaluatedInterpretationContext,
} from "./matilda-history-authority-evaluator";

export interface ComposeMatildaConversationContextInput {
  turns: MatildaConversationTurn[];
  projectContextRetrieval: MatildaProjectContextRetrievalResult;
  interpretationLifecycleEntries?:
    MatildaInterpretationLifecycleEntry[];
}

export interface MatildaConversationContext {
  history: MatildaConversationHistoryContextTurn[];
  interpretations: MatildaInterpretationContext[];
  evaluatedInterpretations:
    MatildaEvaluatedInterpretationContext[];
  projectContextExcerpts:
    MatildaProjectContextRetrievalResult["excerpts"];
  projectContextWarning: string | null;
}

export function composeMatildaConversationContext(
  input: ComposeMatildaConversationContextInput,
): MatildaConversationContext {
  const history =
    assembleMatildaConversationHistoryContext(
      input.turns,
    );

  const interpretations =
    buildInterpretationContext(
      history,
      input.interpretationLifecycleEntries,
    );

  return {
    history,
    interpretations,
    evaluatedInterpretations:
      evaluateMatildaHistoryAuthority(
        interpretations,
      ),
    projectContextExcerpts:
      input.projectContextRetrieval.excerpts,
    projectContextWarning:
      input.projectContextRetrieval.warning,
  };
}
