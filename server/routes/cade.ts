
import express from "express";

import { executeCadeAction } from "../cade/cade-executor";

const router = express.Router();

router.post("/cade/execute", async (req, res) => {

  const { action, payload, executionId } = req.body || {};

  if (!action) {

    return res.status(400).json({

      status: "error",

      error: "missing_action"

    });

  }

  const result = await executeCadeAction({

    action,

    payload,

    executionId

  });

  res.json({

    status: "ok",

    result

  });

});

export default router;

