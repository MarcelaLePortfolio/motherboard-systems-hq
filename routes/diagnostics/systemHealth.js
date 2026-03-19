import express from "express";
import { buildSystemHealthSituationSummaryPayload } from "./systemHealthSituationSummary";

const router = express.Router();

router.get("/", (_req, res) => {
  const situationSummaryPayload = buildSystemHealthSituationSummaryPayload({
    stability: "stable",
    executionRisk: "none",
    cognition: "consistent",
    signalCoherence: "coherent",
    operatorAttention: "none",
  });

  res.json({
    status: "OK",
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    timestamp: new Date().toISOString(),
    ...situationSummaryPayload,
  });
});

export default router;
