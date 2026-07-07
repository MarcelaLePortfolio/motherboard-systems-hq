
import express from "express";

import { createPreviewConfirmation } from "../../db/matilda-preview-confirmation-runtime.js";

const router = express.Router();

router.post("/api/matilda/preview-confirmation", (req, res) => {

  try {

    const {

      preview_id,

      execution_plan_id,

      package_id,

      lineage_id,

      confirmation_actor,

    } = req.body;

    const confirmation = createPreviewConfirmation({

      preview_id,

      execution_plan_id,

      package_id,

      lineage_id,

      confirmation_actor,

    });

    return res.json({

      ok: true,

      route: "matilda_preview_confirmation_route",

      confirmation,

      execution_authorized: false,

    });

  } catch (err) {

    return res.status(400).json({

      ok: false,

      error: err instanceof Error ? (err as any).message : "Unknown error",

    });

  }

});

export default router;

