
import express from "express";

import { createPreview } from "../../db/matilda-preview-runtime.ts";

const router = express.Router();

router.post("/api/matilda/preview", (req, res) => {

  try {

    const {

      execution_plan_id,

      assignment_id,

      package_id,

      lineage_id,

    } = req.body;

    const preview = createPreview({

      execution_plan_id,

      assignment_id,

      package_id,

      lineage_id,

    });

    return res.json({

      ok: true,

      route: "matilda_preview_route",

      preview,

      preview_confirmed: false,

      execution_authorized: false,

    });

  } catch (err) {

    return res.status(400).json({

      ok: false,

      error: err instanceof Error ? err.message : "Unknown error",

    });

  }

});

export default router;

