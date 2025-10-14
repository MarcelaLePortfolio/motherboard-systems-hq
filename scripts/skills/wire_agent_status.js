import fs from "fs";
import path from "path";

export default async function run(params, ctx = {}) {
  const dashboard = path.join(process.cwd(), "public", "dashboard.html");
  let html = fs.readFileSync(dashboard, "utf8");

  // 1️⃣ Ensure frontend has agent status element
  if (!html.includes('id="agents"')) {
    html = html.replace(
      /(<body[^>]*>)/i,
      `$1\n  <section class="card"><h2>🤖 Agent Status</h2><pre id="agents">Loading agent data...</pre></section>`
    );
  }

  // 2️⃣ Ensure updatePanel fetches agent status
  if (!html.includes('/agents/status')) {
    html = html.replace(
      /updatePanel\("system-health-content"/,
      'updatePanel("agents", "/agents/status");\n  updatePanel("system-health-content"'
    );
  }

  fs.writeFileSync(dashboard, html, "utf8");

  // 3️⃣ Create Express route if missing
  const routeDir = path.join(process.cwd(), "routes", "agents");
  const routeFile = path.join(routeDir, "status.js");
  fs.mkdirSync(routeDir, { recursive: true });

  if (!fs.existsSync(routeFile)) {
    fs.writeFileSync(
      routeFile,
      `
import express from "express";
const router = express.Router();

router.get("/status", (req, res) => {
  res.json({
    matilda: "active",
    cade: "online",
    effie: "standby",
    timestamp: new Date().toISOString()
  });
});

export default router;
      `.trim(),
      "utf8"
    );
  }

  return { message: "Agent status wiring complete", file: dashboard };
}
