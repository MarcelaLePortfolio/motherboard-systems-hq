import express from "express";
import { execSync } from "child_process";

const router = express.Router();

router.get("/status", (_req, res) => {
  try {
    // Run PM2 quietly and capture its raw output
    const raw = execSync("pm2 jlist --silent 2>/dev/null || true", { encoding: "utf8" });

    // Extract JSON segment safely
    const start = raw.indexOf("[");
    const end = raw.lastIndexOf("]") + 1;
    if (start === -1 || end === 0) throw new Error("No valid JSON in PM2 output");

    const json = raw.slice(start, end);
    const data = JSON.parse(json);

    const agents = data
      .filter((p: any) => ["matilda", "cade", "effie"].includes(p.name))
      .map((p: any) => ({
        name: p.name,
        status: p.pm2_env?.status ?? "unknown",
        pid: p.pid ?? null,
        cpu: p.monit?.cpu ?? 0,
        memory: p.monit?.memory
          ? `${(p.monit.memory / 1024 / 1024).toFixed(1)} MB`
          : "0 MB",
        uptime: p.pm2_env?.pm_uptime
          ? new Date(Date.now() - p.pm2_env.pm_uptime)
              .toISOString()
              .substring(11, 19)
          : "unknown",
      }));

    res.setHeader("Content-Type", "application/json");
    res.json({ agents });
  } catch (err: any) {
    console.error("Error generating agent status:", err.message);
    res.status(500).json({ error: "Unable to parse PM2 status output" });
  }
});

export default router;
