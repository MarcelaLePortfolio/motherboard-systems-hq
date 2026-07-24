import express, { Request, Response } from "express";
import path from "path";
import { pathToFileURL } from "url";

import { runMatildaStub } from "../matilda-chat-stub";
import type { MatildaChatResult } from "../matilda-chat-stub";
import { runMatildaChatDraftIntegration } from "../db/matilda-chat-draft-integration";
import {
  createMatildaConversation,
  createMatildaConversationTurn,
  getOrCreateActiveMatildaConversation,
  listMatildaConversations,
  listMatildaConversationTurns,
  requireActiveMatildaConversation,
  setActiveMatildaConversation,
  type MatildaConversationTurn,
} from "../db/matilda-conversation-runtime";
import { ollamaChat } from "../scripts/utils/ollamaChat";
import { retrieveMatildaProjectContext } from "../server/matilda-project-context-retrieval";

const router = express.Router();

router.get("/api/chat/conversations", (req: Request, res: Response) => {
  try {
    const projectId =
      typeof req.query.project_id === "string"
        ? req.query.project_id.trim()
        : "";

    if (!projectId) {
      return res.status(400).json({
        ok: false,
        error: "Missing or invalid 'project_id' query parameter.",
      });
    }

    return res.json({
      ok: true,
      project_id: projectId,
      conversations: listMatildaConversations(projectId),
    });
  } catch (error) {
    console.error("[/api/chat/conversations] Error:", error);

    return res.status(500).json({
      ok: false,
      error: "Unable to load Matilda conversations.",
    });
  }
});

router.post("/api/chat/conversations", (req: Request, res: Response) => {
  try {
    const projectId =
      typeof req.body?.project_id === "string"
        ? req.body.project_id.trim()
        : "";

    if (!projectId) {
      return res.status(400).json({
        ok: false,
        error: "Missing or invalid 'project_id' in request body.",
      });
    }

    const conversation = createMatildaConversation(projectId);

    return res.status(201).json({
      ok: true,
      project_id: projectId,
      conversation,
      conversations: listMatildaConversations(projectId),
    });
  } catch (error) {
    console.error("[POST /api/chat/conversations] Error:", error);

    return res.status(500).json({
      ok: false,
      error: "Unable to create Matilda conversation.",
    });
  }
});

router.post("/api/chat/conversations/active", (req: Request, res: Response) => {
  try {
    const projectId =
      typeof req.body?.project_id === "string"
        ? req.body.project_id.trim()
        : "";
    const conversationId =
      typeof req.body?.conversation_id === "string"
        ? req.body.conversation_id.trim()
        : "";

    if (!projectId || !conversationId) {
      return res.status(400).json({
        ok: false,
        error:
          "Missing or invalid 'project_id' or 'conversation_id' in request body.",
      });
    }

    const conversation = setActiveMatildaConversation(
      projectId,
      conversationId
    );

    return res.json({
      ok: true,
      project_id: projectId,
      conversation,
      conversations: listMatildaConversations(projectId),
    });
  } catch (error) {
    console.error("[POST /api/chat/conversations/active] Error:", error);

    return res.status(404).json({
      ok: false,
      error:
        error instanceof Error
          ? error.message
          : "Unable to switch Matilda conversation.",
    });
  }
});

router.get("/api/chat/history", (req: Request, res: Response) => {
  try {
    const projectId =
      typeof req.query.project_id === "string"
        ? req.query.project_id.trim()
        : "";

    if (!projectId) {
      return res.status(400).json({
        ok: false,
        error: "Missing or invalid 'project_id' query parameter.",
      });
    }

    const conversation = getOrCreateActiveMatildaConversation(projectId);
    const turns = listMatildaConversationTurns(
      projectId,
      100,
      conversation.conversation_id
    );

    return res.json({
      ok: true,
      project_id: projectId,
      conversation_id: conversation.conversation_id,
      turns,
    });
  } catch (error) {
    console.error("[/api/chat/history] Error:", error);

    return res.status(500).json({
      ok: false,
      error: "Unable to load Matilda chat history.",
    });
  }
});

router.post("/api/chat", async (req: Request, res: Response) => {
  try {
    const { message, agent, project_id, conversation_id } =
      (req.body || {}) as {
        message?: string;
        agent?: string | null;
        project_id?: string | null;
        conversation_id?: string | null;
      };

    if (typeof message !== "string" || !message.trim()) {
      return res.status(400).json({
        ok: false,
        error: "Missing or invalid 'message' in request body.",
      });
    }

    const normalizedProjectId =
      typeof project_id === "string" ? project_id.trim() : "";
    const normalizedConversationId =
      typeof conversation_id === "string"
        ? conversation_id.trim()
        : "";

    if (!normalizedProjectId || !normalizedConversationId) {
      return res.status(400).json({
        ok: false,
        error:
          "Missing or invalid 'project_id' or 'conversation_id' in request body.",
      });
    }

    try {
      requireActiveMatildaConversation(
        normalizedProjectId,
        normalizedConversationId
      );
    } catch (error) {
      return res.status(409).json({
        ok: false,
        error:
          error instanceof Error
            ? error.message
            : "Matilda conversation is unavailable.",
      });
    }

    const result: MatildaChatResult = await runMatildaStub({
      message,
      agent: agent ?? "matilda",
      project_id: normalizedProjectId,
      conversation_id: normalizedConversationId,
    });

    let draftPackageUpdated = false;

    try {
      runMatildaChatDraftIntegration({
        project_id: normalizedProjectId,
        conversation_id: normalizedConversationId,
        draft_package_id: `matilda-draft-${normalizedConversationId}`,
        lineage_id: `matilda-lineage-${normalizedConversationId}`,
        latest_entry_id: result.meta.interpretation_entry_id,
      });

      draftPackageUpdated = true;
    } catch (draftError) {
      console.warn("[/api/chat] Draft synthesis failed:", draftError);
    }

    let conversationalReply: string;
    let persistedTurn: MatildaConversationTurn | null = null;

    try {
      let projectDisplayName: string | null = null;
      let projectRootPath: string | null = null;

      const registryPath = pathToFileURL(
        path.resolve(process.cwd(), "server", "project-registry.mjs")
      ).href;

      const { getProjectRegistryState } = await import(registryPath);
      const registryState = getProjectRegistryState();
      const project = registryState.projects.find(
        (candidate: { projectId: string }) =>
          candidate.projectId === normalizedProjectId
      );

      projectDisplayName = project?.displayName ?? null;
      projectRootPath = project?.projectRootPath ?? null;

      const projectContextRetrieval = retrieveMatildaProjectContext({
        projectId: normalizedProjectId,
        projectRootPath,
        message: message.trim(),
      });

      const activeConversation =
        getOrCreateActiveMatildaConversation(normalizedProjectId);
      const resolvedConversationId =
        normalizedConversationId || activeConversation.conversation_id;

      const history = listMatildaConversationTurns(
        normalizedProjectId,
        20,
        resolvedConversationId
      ).map((turn) => ({
        userMessage: turn.user_message,
        assistantReply: turn.assistant_reply,
      }));

      conversationalReply = await ollamaChat(message.trim(), {
        projectId: normalizedProjectId,
        projectDisplayName,
        history,
        projectContextExcerpts: projectContextRetrieval.excerpts,
        projectContextWarning: projectContextRetrieval.warning,
      });

      persistedTurn = createMatildaConversationTurn({
        project_id: normalizedProjectId,
        conversation_id: resolvedConversationId,
        user_message: message.trim(),
        assistant_reply: conversationalReply,
        interpretation_entry_id: result.meta.interpretation_entry_id,
      });
    } catch (ollamaError) {
      console.error("[/api/chat] Ollama response failed:", ollamaError);

      return res.status(503).json({
        ok: false,
        error: "Matilda's conversational model is currently unavailable.",
      });
    }

    if (!persistedTurn) {
      return res.status(500).json({
        ok: false,
        error: "Matilda's conversation turn was not persisted.",
      });
    }

    return res.json({
      ...result,
      reply: conversationalReply,
      turn: persistedTurn,
      draft_package_updated: draftPackageUpdated,
      canonical_package_created: false,
      delegation_authorized: false,
      validation_authorized: false,
      envelope_authorized: false,
      execution_authorized: false,
    });
  } catch (err) {
    console.error("[/api/chat] Error:", err);

    return res.status(500).json({
      ok: false,
      error: "Unexpected error",
    });
  }
});

export default router;
