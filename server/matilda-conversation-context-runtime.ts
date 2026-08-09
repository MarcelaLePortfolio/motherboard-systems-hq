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
import {
  evaluateMatildaHistoryContamination,
  type MatildaContaminationEvaluatedInterpretation,
} from "./matilda-history-contamination-evaluator";
import {
  selectMatildaConversationHistory,
  type MatildaSelectedHistoryTurn,
} from "./matilda-history-selection-runtime";

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
  contaminationEvaluations:
    MatildaContaminationEvaluatedInterpretation[];
  selectedHistory:
    MatildaSelectedHistoryTurn[];
  projectContextExcerpts:
    MatildaProjectContextRetrievalResult["excerpts"];
  projectContextSegmentCandidates:
    MatildaProjectContextRetrievalResult["projectContextSegmentCandidates"];
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

  const evaluatedInterpretations =
    evaluateMatildaHistoryAuthority(
      interpretations,
    );

  const contaminationEvaluations =
    evaluateMatildaHistoryContamination(
      evaluatedInterpretations,
    );

  const selectedHistory =
    selectMatildaConversationHistory(
      history,
      contaminationEvaluations,
    );

  return {
    history,
    interpretations,
    evaluatedInterpretations,
    contaminationEvaluations,
    selectedHistory,
    projectContextExcerpts:
      input.projectContextRetrieval.excerpts,
    projectContextSegmentCandidates:
      input.projectContextRetrieval
        .projectContextSegmentCandidates,
    projectContextWarning:
      input.projectContextRetrieval.warning,
  };
}
