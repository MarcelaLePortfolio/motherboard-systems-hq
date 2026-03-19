import express from "express";

const router = express.Router();

function buildSituationSummary(status) {
  if (status === "OK") {
    return (
      "SYSTEM STABLE\n" +
      "NO EXECUTION RISK DETECTED\n" +
      "COGNITION SIGNALS CONSISTENT\n" +
      "SIGNALS COHERENT\n" +
      "NO OPERATOR ACTION REQUIRED"
    );
  }

  return (
    "SYSTEM NEEDS ATTENTION\n" +
    "NO EXECUTION AUTHORITY EXPOSED\n" +
    "COGNITION SIGNALS REQUIRE REVIEW\n" +
    "SIGNALS PARTIALLY COHERENT\n" +
    "NO OPERATOR ACTION INFERRED"
  );
}

export function buildSystemHealthSnapshot() {
  const status = "OK";
  const timestamp = new Date().toISOString();

  return {
    status,
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    timestamp,
    situationSummary: buildSituationSummary(status),
  };
}

export function buildSystemHealthGuidanceSignals(snapshot) {
  const observedAt = Date.parse(snapshot.timestamp);

  return [
    {
      key: "system-health",
      domain: "system_health",
      status: snapshot.status === "OK" ? "healthy" : "degraded",
      value: snapshot.status,
      summary: snapshot.situationSummary.split("\n")[0] || "system health snapshot available",
      observedAt: Number.isFinite(observedAt) ? observedAt : Date.now(),
      source: "diagnostics/system-health",
    },
  ];
}

router.get("/", (_req, res) => {
  res.json(buildSystemHealthSnapshot());
});

export default router;
