#!/usr/bin/env tsx
/**
 * Dev Server with Accurate PM2 Status
 */
import { createServer } from "http";
import { readFileSync, existsSync } from "fs";
import { join } from "path";
import { execSync } from "child_process";

const PORT = 3000;
const UI_DIR = join(process.cwd(), "ui", "dashboard");

function getAgentStatus() {
  try {
    const output = execSync("pm2 jlist", { encoding: "utf-8" });
    const list = JSON.parse(output);

    const statusMap: Record<string, string> = {
      matilda: "offline",
      cade: "offline",
      effie: "offline",
    };

    for (const app of list) {
      const name = app.name?.toLowerCase();
      const status = app.pm2_env?.status || "stopped";

      if (name?.includes("matilda")) statusMap.matilda = status === "online" ? "online" : "offline";
      if (name?.includes("cade")) statusMap.cade = status === "online" ? "online" : "offline";
      if (name?.includes("effie")) statusMap.effie = status === "online" ? "online" : "offline";
    }

    return statusMap;
  } catch (err) {
    console.error("❌ Failed to fetch PM2 status:", err);
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
  } else {
    res.writeHead(404);
    res.end("Not Found");
  }
}).listen(PORT, () => {
  console.log(`✅ Dev server with accurate PM2 status running at http://localhost:${PORT}`);
});
