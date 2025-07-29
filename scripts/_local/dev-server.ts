/**
 * Dev Server with PM2 Health Integration
 * --------------------------------------
 * Serves dashboard files and provides /agent-status.json
 * that reflects actual PM2 process health.
 */

import { createServer } from "http";
import { readFileSync, existsSync } from "fs";
import { execSync } from "child_process";
import { join } from "path";

const PORT = 3000;
const ROOT = process.cwd();
const UI_DIR = join(ROOT, "ui", "dashboard");

function getAgentStatus() {
  try {
    const raw = execSync("pm2 jlist", { encoding: "utf-8" });
    const list = JSON.parse(raw);

    const statusMap: Record<string, string> = { matilda: "offline", cade: "offline", effie: "offline" };

    for (const proc of list) {
      const name = (proc.name || "").toLowerCase();
      const status = proc.pm2_env?.status || "stopped";

      if (name.includes("matilda")) statusMap.matilda = status === "online" ? "online" : "offline";
      if (name.includes("cade")) statusMap.cade = status === "online" ? "online" : "offline";
      if (name.includes("effie")) statusMap.effie = status === "online" ? "online" : "offline";
    }

    return statusMap;
  } catch (err) {
    return { matilda: "offline", cade: "offline", effie: "offline" };
  }
}

createServer((req, res) => {
  if (req.url === "/agent-status.json") {
    const status = getAgentStatus();
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify(status));
    return;
  }

  // serve dashboard static files
  let filePath = join(UI_DIR, req.url || "/");
  if (filePath.endsWith("/")) filePath += "index.html";

  if (existsSync(filePath)) {
    const ext = filePath.split(".").pop()?.toLowerCase() || "";
    const mime =
      ext === "html" ? "text/html" :
      ext === "js"   ? "application/javascript" :
      ext === "css"  ? "text/css" :
      "text/plain";

    res.writeHead(200, { "Content-Type": mime });
    res.end(readFileSync(filePath));
  } else if (req.url === "/favicon.ico") {
    res.writeHead(204); // no content
    res.end();
  } else {
    res.writeHead(404);
    res.end("Not Found");
  }
}).listen(PORT, () => {
  console.log(`✅ Dev server with PM2 health check running at http://localhost:${PORT}`);
});
