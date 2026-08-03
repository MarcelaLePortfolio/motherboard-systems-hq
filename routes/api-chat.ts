import express, { Request, Response } from "express";

import {
  createMatildaConversation,
  getOrCreateActiveMatildaConversation,
  listMatildaConversations,
  listMatildaConversationTurns,
  requireActiveMatildaConversation,
  setActiveMatildaConversation,
} from "../db/matilda-conversation-runtime";
import {
  MatildaConversationWorkflowUnavailableError,
  runMatildaConversationWorkflow,
} from "../server/matilda-chat-workflow";

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
      conversationId,
    );

    return res.json({
      ok: true,
      project_id: projectId,
      conversation,
      conversations: listMatildaConversations(projectId),
    });
  } catch (error) {
    console.error(
      "[POST /api/chat/conversations/active] Error:",
      error,
    );

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

    const conversation =
      getOrCreateActiveMatildaConversation(projectId);

    const turns = listMatildaConversationTurns(
      projectId,
      100,
      conversation.conversation_id,
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
      typeof project_id === "string"
        ? project_id.trim()
        : "";

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
        normalizedConversationId,
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

    try {
      const result = await runMatildaConversationWorkflow({
        message: message.trim(),
        agent: agent ?? "matilda",
        project_id: normalizedProjectId,
        conversation_id: normalizedConversationId,
      });

      return res.json(result);
    } catch (workflowError) {
      if (
        workflowError instanceof
        MatildaConversationWorkflowUnavailableError
      ) {
        return res.status(503).json({
          ok: false,
          error: workflowError.message,
        });
      }

      throw workflowError;
    }
  } catch (error) {
    console.error("[/api/chat] Error:", error);

    return res.status(500).json({
      ok: false,
      error: "Unexpected error",
    });
  }
});

export default router;
