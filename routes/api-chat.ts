
import express, { Request, Response } from "express";
import path from "path";
import { pathToFileURL } from "url";

import { runMatildaStub } from "../matilda-chat-stub";

import type { MatildaChatResult } from "../matilda-chat-stub";

import { runMatildaChatDraftIntegration } from "../db/matilda-chat-draft-integration";
import {
  createMatildaConversationTurn,
  listMatildaConversationTurns,
} from "../db/matilda-conversation-runtime";
import { ollamaChat } from "../scripts/utils/ollamaChat";

const router = express.Router();

router.post("/api/chat", async (req: Request, res: Response) => {

  try {

    const { message, agent, project_id } = (req.body || {}) as {

      message?: string;

      agent?: string | null;

      project_id?: string | null;

    };

    if (typeof message !== "string" || !message.trim()) {

      return res.status(400).json({

        ok: false,

        error: "Missing or invalid 'message' in request body.",

      });

    }

    const result: MatildaChatResult = await runMatildaStub({

      message,

      agent: agent ?? "matilda",

      project_id,

    });

    let draftPackageUpdated = false;

    try {

      if (project_id) {

        runMatildaChatDraftIntegration({

          draft_package_id: `matilda-draft-${project_id}`,

          lineage_id: `matilda-lineage-${project_id}`,

          latest_entry_id: result.meta.interpretation_entry_id,

        });

        draftPackageUpdated = true;

      }

    } catch (draftError) {

      console.warn("[/api/chat] Draft synthesis failed:", draftError);

    }

    let conversationalReply: string;

    try {

      let projectDisplayName: string | null = null;

      if (project_id) {

        const registryPath = pathToFileURL(
          path.resolve(process.cwd(), "server", "project-registry.mjs")
        ).href;

        const { getProjectRegistryState } = await import(registryPath);
        const registryState = getProjectRegistryState();

        const project = registryState.projects.find(
          (candidate: { projectId: string }) =>
            candidate.projectId === project_id
        );

        projectDisplayName = project?.displayName ?? null;

      }

      const history = project_id
        ? listMatildaConversationTurns(project_id, 20).map((turn) => ({
            userMessage: turn.user_message,
            assistantReply: turn.assistant_reply,
          }))
        : [];

      conversationalReply = await ollamaChat(message.trim(), {
        projectId: project_id,
        projectDisplayName,
        history,
      });

      if (project_id) {
        createMatildaConversationTurn({
          project_id,
          user_message: message.trim(),
          assistant_reply: conversationalReply,
          interpretation_entry_id: result.meta.interpretation_entry_id,
        });
      }

    } catch (ollamaError) {

      console.error("[/api/chat] Ollama response failed:", ollamaError);

      return res.status(503).json({
        ok: false,
        error: "Matilda's conversational model is currently unavailable.",
      });

    }

    return res.json({

      ...result,

      reply: conversationalReply,

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

