
import express, { Request, Response } from "express";

import { runMatildaStub } from "../matilda-chat-stub";

import type { MatildaChatResult } from "../matilda-chat-stub";

import { runMatildaChatDraftIntegration } from "../db/matilda-chat-draft-integration";

const router = express.Router();

router.post("/api/chat", async (req: Request, res: Response) => {

  try {

    const { message, agent } = (req.body || {}) as {

      message?: string;

      agent?: string | null;

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

    });

    let draftPackageUpdated = false;

    try {

      runMatildaChatDraftIntegration({

        draft_package_id: "draft-active-conversation",

        lineage_id: "matilda-active-conversation",

        latest_entry_id: result.meta.interpretation_entry_id,

      });

      draftPackageUpdated = true;

    } catch (draftError) {

      console.warn("[/api/chat] Draft synthesis failed:", draftError);

    }

    return res.json({

      ...result,

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

