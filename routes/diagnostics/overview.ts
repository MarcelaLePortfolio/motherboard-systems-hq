
import express from "express";

const router = express.Router();

router.get("/overview", (req: any, res) => {

  const authority = req.authority ?? {

    execution_authorized: false,

    reason: "missing_middleware",

    confidence: 0

  };

  const system =

    authority.confidence > 0.8 ? "healthy"

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

