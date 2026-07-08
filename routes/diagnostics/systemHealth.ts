
import express from "express";

const router = express.Router();

/**

 * NOW fully middleware-driven (no direct evaluation)

 */

router.get("/system-health", (req: any, res) => {

  const authority = req.authority ?? {

    execution_authorized: false,

    reason: "missing_middleware",

    confidence: 0

  };

  const healthScore =

    authority.confidence > 0.8 ? "strong"

    : authority.confidence > 0.5 ? "stable"

    : "degraded";

  const systemStatus =

    authority.execution_authorized && authority.confidence > 0.8

      ? "healthy"

      : authority.confidence > 0.5

        ? "degraded"

        : "unstable";

  res.json({

    status: "ok",

    system: systemStatus,

    healthScore,

    authority

  });

});

export { router };

export default router;

