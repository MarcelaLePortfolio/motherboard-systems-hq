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
  // Phase 464.X SAFE PATCH — normalize output without overriding logic
  if (Array.isArray(payload)) {
    const seen = new Set();
    payload = payload.filter(item => {
      const key = JSON.stringify(item);
      if (seen.has(key)) return false;
      seen.add(key);
      return true;
    });
  }
    status: "OK",
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    timestamp: new Date().toISOString(),
    ...situationSummaryPayload,
  });
});

export default router;
