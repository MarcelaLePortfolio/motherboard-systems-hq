import path from "path";
import { pathToFileURL } from "url";

import {
  runMatildaStub,
  type MatildaChatResult,
} from "../matilda-chat-stub";
import { runMatildaChatDraftIntegration } from "../db/matilda-chat-draft-integration";
import { createInterpretationEvidenceLedgerEntry } from "../db/matilda-interpretation-runtime";
import {
  createMatildaConversationTurn,
  listMatildaConversationTurns,
  type MatildaConversationTurn,
} from "../db/matilda-conversation-runtime";
import { ollamaChat } from "../scripts/utils/ollamaChat";
import { retrieveMatildaProjectContext } from "./matilda-project-context-retrieval";

export interface RunMatildaConversationWorkflowInput {
  message: string;
  agent?: string | null;
  project_id: string;
  conversation_id: string;
}

export type MatildaConversationWorkflowResult = MatildaChatResult & {
  reply: string;
  turn: MatildaConversationTurn;
  draft_package_updated: boolean;
  canonical_package_created: false;
  delegation_authorized: false;
  validation_authorized: false;
  envelope_authorized: false;
  execution_authorized: false;
};

export class MatildaConversationWorkflowUnavailableError extends Error {
  constructor(
    message =
      "Matilda's conversational model is currently unavailable.",
  ) {
    super(message);
    this.name = "MatildaConversationWorkflowUnavailableError";
    Object.setPrototypeOf(
      this,
      MatildaConversationWorkflowUnavailableError.prototype,
    );
  }
}

function clampText(value: string, maxLength = 4000): string {
  const text = String(value || "").trim();

  return text.length > maxLength
    ? `${text.slice(0, maxLength - 1)}…`
    : text;
}

export async function runMatildaConversationWorkflow(
  input: RunMatildaConversationWorkflowInput,
): Promise<MatildaConversationWorkflowResult> {
  const message = input.message.trim();
  const projectId = input.project_id.trim();
  const conversationId = input.conversation_id.trim();

  const result: MatildaChatResult = await runMatildaStub({
    message,
    agent: input.agent ?? "matilda",
    project_id: projectId,
    conversation_id: conversationId,
  });

  try {
    let projectDisplayName: string | null = null;
    let projectRootPath: string | null = null;

    const registryPath = pathToFileURL(
      path.resolve(
        process.cwd(),
        "server",
        "project-registry.mjs",
      ),
    ).href;

    const { getProjectRegistryState } = await import(registryPath);
    const registryState = getProjectRegistryState();

    const project = registryState.projects.find(
      (candidate: { projectId: string }) =>
        candidate.projectId === projectId,
    );

    projectDisplayName = project?.displayName ?? null;
    projectRootPath = project?.projectRootPath ?? null;

    const projectContextRetrieval =
      retrieveMatildaProjectContext({
        projectId,
        projectRootPath,
        message,
      });

    const history = listMatildaConversationTurns(
      projectId,
      20,
      conversationId,
    ).map((turn) => ({
      userMessage: turn.user_message,
      assistantReply: turn.assistant_reply,
    }));

    const conversationalReply = await ollamaChat(message, {
      projectId,
      projectDisplayName,
      history,
      projectContextExcerpts:
        projectContextRetrieval.excerpts,
      projectContextWarning:
        projectContextRetrieval.warning,
    });

    createInterpretationEvidenceLedgerEntry({
      entry_id: result.meta.interpretation_entry_id,
      actor: result.agent,
      project_id: projectId,
      conversation_id: conversationId,
      interpretation_event:
        "Matilda received a chat interaction and preserved upstream interpretation evidence before any Package creation.",
      minimum_sufficient_context:
        "Matilda chat interaction received through /api/chat during the Conversation Engine IEL integration corridor.",
      supporting_raw_evidence: clampText(message),
      matilda_observation:
        "This entry preserves conversation evidence only. It is upstream of Draft Package synthesis, Reconciled Intent Summary generation, approval, canonical Package creation, delegation, validation, envelope creation, routing, assignment, and Cade execution.",
      unresolved_questions:
        "Future corridor must determine how this evidence updates a living Draft Package and when the conversation becomes reconciliation-ready.",
      lineage_references:
        "MATILDA_NEXT_CORRIDOR_HANDOFF_2026-07-05.md; MATILDA_INTERPRETATION_EVIDENCE_LEDGER_RUNTIME_VALIDATED_2026-07-05.md",
      supersession_status: "current",
    });

    const persistedTurn = createMatildaConversationTurn({
      project_id: projectId,
      conversation_id: conversationId,
      user_message: message,
      assistant_reply: conversationalReply,
      interpretation_entry_id:
        result.meta.interpretation_entry_id,
      project_context_retrieval:
        projectContextRetrieval,
    });

    let draftPackageUpdated = false;

    try {
      runMatildaChatDraftIntegration({
        project_id: projectId,
        conversation_id: conversationId,
        draft_package_id: `matilda-draft-${conversationId}`,
        lineage_id: `matilda-lineage-${conversationId}`,
        latest_entry_id: result.meta.interpretation_entry_id,
      });

      draftPackageUpdated = true;
    } catch (draftError) {
      console.warn(
        "[Matilda conversation workflow] Draft synthesis failed:",
        draftError,
      );
    }

    return {
      ...result,
      reply: conversationalReply,
      turn: persistedTurn,
      draft_package_updated: draftPackageUpdated,
      canonical_package_created: false,
      delegation_authorized: false,
      validation_authorized: false,
      envelope_authorized: false,
      execution_authorized: false,
    };
  } catch (workflowError) {
    console.error(
      "[Matilda conversation workflow] Conversational response failed:",
      workflowError,
    );

    throw new MatildaConversationWorkflowUnavailableError();
  }
}
