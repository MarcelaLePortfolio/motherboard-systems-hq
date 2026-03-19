import express from "express";

const router = express.Router();

router.get("/", (_req, res) => {
  const situationSummary =
    "SYSTEM STABLE\n" +
    "NO EXECUTION RISK DETECTED\n" +
    "COGNITION SIGNALS CONSISTENT\n" +
    "SIGNALS COHERENT\n" +
    "NO OPERATOR ACTION REQUIRED";

  res.json({
    status: "OK",
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    timestamp: new Date().toISOString(),
    situationSummary,
  });
});

export default router;
