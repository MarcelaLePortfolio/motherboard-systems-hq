
import express from "express";

import { evaluateAuthority } from "../../server/authority/authority-gate";

const router = express.Router();

router.get("/system-health", (req, res) => {

  const rawMode = req.query.mode;

  const mode =

    rawMode === "simulation" || rawMode === "runtime" || rawMode === "diagnostic"

      ? rawMode

      : "diagnostic";

  const authority = evaluateAuthority({

    mode,

    source: "systemHealth"

  });

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

