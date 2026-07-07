
import express from "express";

import { createExecutionAuthorization } from "../../db/matilda-execution-authorization-runtime.js";

const router = express.Router();

router.post("/api/matilda/execution-authorization", (req, res) => {

  try {

    const {

      confirmation_id,

      preview_id,

      execution_plan_id,

      package_id,

      lineage_id,

      authorization_actor,

    } = req.body;

    const authorization = createExecutionAuthorization({

      confirmation_id,

      preview_id,

      execution_plan_id,

      package_id,

      lineage_id,

      authorization_actor,

    });

    return res.json({

      ok: true,

      route: "matilda_execution_authorization_route",

      authorization,

      cade_execution_started: false,

    });

  } catch (err) {

    return res.status(400).json({

      ok: false,

      error: err instanceof Error ? (err as any).message : "Unknown error",

    });

  }

});

export default router;

