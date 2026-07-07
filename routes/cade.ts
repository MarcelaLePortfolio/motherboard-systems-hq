
import express from "express";

import { executeCadeAction } from "../server/cade/cade-executor";

const router = express.Router();

/**

 * Minimal execution gateway for Cade

 */

router.post("/cade/execute", async (req, res) => {

  const result = await executeCadeAction({

    action: req.body.action,

    payload: req.body.payload

  });

  res.json({

    status: "ok",

    result

  });

});

export default router;

