import express from "express";
const router = express.Router();




import { buildSystemHealthSituationSummaryPayload } from "./systemHealthSituationSummary";


export function buildSystemHealthSnapshot() {

  const situationSummaryPayload = buildSystemHealthSituationSummaryPayload({

    stability: "stable",

    executionRisk: "none",

    cognition: "consistent",

    signalCoherence: "coherent",

    operatorAttention: "none",

  });

  return {

    status: "OK",

    uptime: process.uptime(),

    memory: process.memoryUsage(),

    timestamp: new Date().toISOString(),

    ...situationSummaryPayload,

  };

}

export function buildSystemHealthGuidanceSignals(snapshot: ReturnType<typeof buildSystemHealthSnapshot>) {

  const observedAt = Date.parse(snapshot.timestamp);

  return [

    {

      key: "system-health",

      domain: "system_health",

      status: snapshot.status === "OK" ? "healthy" : "degraded",

      value: snapshot.status,

      summary:

        typeof snapshot.situationSummary === "string"

          ? snapshot.situationSummary.split("\n")[0] || "system health snapshot available"

          : "system health snapshot available",

      observedAt: Number.isFinite(observedAt) ? observedAt : Date.now(),

      source: "diagnostics/system-health",

    },

  ];

}

router.get("/", (_req, res) => {

  res.json(buildSystemHealthSnapshot());

});


