
import express from "express";

import { evaluateAuthority } from "../../server/authority/authority-gate";

const router = express.Router();

router.get("/overview", (req, res) => {

  const authority = evaluateAuthority({

    mode: "diagnostic",

    source: "overview"

  });

  const system = authority.confidence > 0.8 ? "healthy"

    : authority.confidence > 0.5 ? "degraded"

    : "unstable";

  res.json({

    status: "ok",

    system,

    authority,

    timestamp: Date.now()

  });

});

export { router };

export default router;

