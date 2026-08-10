import path from "path";
import { pathToFileURL } from "url";

import {
  runMatildaStub,
  type MatildaChatResult,
} from "../matilda-chat-stub";
import { runMatildaChatDraftIntegration } from "../db/matilda-chat-draft-integration";
import {
  createInterpretationEvidenceLedgerEntry,
  listInterpretationEvidenceLedgerEntries,
} from "../db/matilda-interpretation-runtime";
import {
  createMatildaConversationTurn,
  listMatildaConversationTurns,
  type MatildaConversationTurn,
} from "../db/matilda-conversation-runtime";
import { ollamaChat } from "../scripts/utils/ollamaChat";
import {
  isExplicitExplanationRequest,
} from "./matilda-explanation-request-signal";
import {
  isExplicitEvidenceRequest,
} from "./matilda-evidence-request-signal";
import {
  recoverMatildaPriorSupportProvenance,
} from "./matilda-prior-support-provenance";
import {
  createMatildaPersistedSupportProvenance,
} from "./matilda-support-provenance";
import { retrieveMatildaProjectContext } from "./matilda-project-context-retrieval";
import { composeMatildaConversationContext } from "./matilda-conversation-context-runtime";
import {
  selectMatildaInterpretationLifecycleEntries,
} from "./matilda-interpretation-lifecycle-provider";

export interface RunMatildaConversationWorkflowInput {
  message: string;
  agent?: string | null;
  project_id: string;
  conversation_id: string;
}

export type MatildaConversationWorkflowResult =
  MatildaChatResult & {
    reply: string;
    turn: MatildaConversationTurn;
    draft_package_updated: boolean;
    canonical_package_created: false;
    delegation_authorized: false;
    validation_authorized: false;
    envelope_authorized: false;
    execution_authorized: false;
  };

export class MatildaConversationWorkflowUnavailableError
  extends Error {
  constructor(
    message =
      "Matilda's conversational model is currently unavailable.",
  ) {
    super(message);
    this.name =
      "MatildaConversationWorkflowUnavailableError";
    Object.setPrototypeOf(
      this,
      MatildaConversationWorkflowUnavailableError
        .prototype,
    );
  }
}

function clampText(
  value: string,
  maxLength = 4000,
): string {
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
  const conversationId =
    input.conversation_id.trim();

  const result: MatildaChatResult =
    await runMatildaStub({
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

    const {
      getProjectRegistryState,
    } = await import(registryPath);

    const registryState =
      getProjectRegistryState();

    const project =
      registryState.projects.find(
        (candidate: {
          projectId: string;
          displayName?: string | null;
          projectRootPath?: string | null;
        }) =>
          candidate.projectId === projectId,
      );

    projectDisplayName =
      project?.displayName ?? null;

    projectRootPath =
      project?.projectRootPath ?? null;

    const projectContextRetrieval =
      retrieveMatildaProjectContext({
        projectId,
        projectRootPath,
        message,
      });

    const conversationTurns =
      listMatildaConversationTurns(
        projectId,
        20,
        conversationId,
      );

    const interpretationLedgerEntries =
      listInterpretationEvidenceLedgerEntries(500);

    const interpretationLifecycleEntries =
      selectMatildaInterpretationLifecycleEntries(
        conversationTurns.map(
          (turn) => turn.interpretation_entry_id,
        ),
        interpretationLedgerEntries,
      );

    const conversationContext =
      composeMatildaConversationContext({
        turns: conversationTurns,
        projectContextRetrieval,
        interpretationLifecycleEntries,
      });

    const history =
      conversationContext.selectedHistory;

    const explicitExplanationRequest =
      isExplicitExplanationRequest(message);

    const explicitEvidenceRequest =
      isExplicitEvidenceRequest(message);

    const priorSupportProvenance =
      explicitExplanationRequest
        ? recoverMatildaPriorSupportProvenance(
            history,
            interpretationLedgerEntries,
          )
        : null;

    const ollamaResult =
      await ollamaChat(message, {
        projectId,
        projectDisplayName,
        history,
        projectContextExcerpts:
          conversationContext.projectContextExcerpts,
        projectContextSegmentCandidates:
          conversationContext
            .projectContextSegmentCandidates,
        projectContextWarning:
          conversationContext.projectContextWarning,
        priorExplanationEvidenceStatus:
          priorSupportProvenance?.status,
        explicitEvidenceRequest,
      });

    const conversationalReply =
      ollamaResult.reply;

    const durableInterpretation =
      ollamaResult.durableInterpretation;

    const supportProvenance =
      createMatildaPersistedSupportProvenance(
        ollamaResult.supportSourceReferences,
        ollamaResult.evidenceSufficient,
      );

    createInterpretationEvidenceLedgerEntry({
      entry_id:
        result.meta.interpretation_entry_id,
      actor: result.agent,
      project_id: projectId,
      conversation_id: conversationId,
      interpretation_event:
        "Matilda interpreted the current project-scoped conversation turn using available conversation history and bounded project evidence.",
      minimum_sufficient_context: [
        `project:${projectId}`,
        `conversation:${conversationId}`,
        `prior_turns:${history.length}`,
        `project_context_excerpts:${projectContextRetrieval.excerpts.length}`,
        projectContextRetrieval.warning
          ? "project_context_warning:present"
          : "project_context_warning:none",
      ].join("; "),
      supporting_raw_evidence: clampText(
        JSON.stringify({
          user_message: message,
          prior_turn_count: history.length,
          project_context_sources:
            projectContextRetrieval.excerpts.map(
              (excerpt) => ({
                relative_path:
                  excerpt.relativePath,
                line_number:
                  excerpt.lineNumber,
                provenance:
                  excerpt.provenance,
                authority_status:
                  excerpt.authorityStatus,
              }),
            ),
          project_context_warning:
            projectContextRetrieval.warning,
          support_source_references:
            supportProvenance
              .supportSourceReferences,
          evidence_sufficient:
            supportProvenance
              .evidenceSufficient,
        }),
        12000,
      ),
      matilda_observation:
        durableInterpretation,
      unresolved_questions: null,
      lineage_references: [
        `project:${projectId}`,
        `conversation:${conversationId}`,
        `interpretation_entry:${result.meta.interpretation_entry_id}`,
      ].join("; "),
      supersession_status: "current",
      investigation_lifecycle:
        ollamaResult.investigationLifecycle,
    });

    const persistedTurn =
      createMatildaConversationTurn({
        project_id: projectId,
        conversation_id:
          conversationId,
        user_message: message,
        assistant_reply:
          conversationalReply,
        interpretation_entry_id:
          result.meta
            .interpretation_entry_id,
        project_context_retrieval:
          projectContextRetrieval,
      });

    let draftPackageUpdated = false;

    try {
      runMatildaChatDraftIntegration({
        project_id: projectId,
        conversation_id:
          conversationId,
        draft_package_id:
          `matilda-draft-${conversationId}`,
        lineage_id:
          `matilda-lineage-${conversationId}`,
        latest_entry_id:
          result.meta
            .interpretation_entry_id,
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
      draft_package_updated:
        draftPackageUpdated,
      canonical_package_created:
        false,
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
