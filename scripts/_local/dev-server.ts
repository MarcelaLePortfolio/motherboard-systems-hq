import { execSync } from "child_process";
import http from "http";
import { createServer } from "http";
import { join } from "path";
import { existsSync, readFileSync } from "fs";

const UI_DIR = join(process.cwd(), "ui/dashboard");
const PORT = 3000;

async function pingAgent(port: number) {
  return new Promise<boolean>((resolve) => {
    const req = http.get({ hostname: "localhost", port, path: "/", timeout: 1000 }, (res) => {
      resolve(res.statusCode === 200);
    });
    req.on("error", () => resolve(false));
    req.on("timeout", () => {
      req.destroy();
      resolve(false);
    });
  });
}

async function getAgentStatus() {
  const statusMap = { matilda: "offline", cade: "offline", effie: "offline" };
  try {
    const raw = execSync("pm2 jlist").toString();
    const list = JSON.parse(raw);

    for (const proc of list) {
      const name = proc.name.toLowerCase();
      if (statusMap[name] !== undefined) {
        statusMap[name] = "online"; // base on PM2 first
      }
    }

    // ✅ Confirm HTTP heartbeat
    if (await pingAgent(3012)) statusMap.cade = "online";
    if (await pingAgent(3013)) statusMap.effie = "online";

    return statusMap;
  } catch (err) {
    console.error("❌ Failed to fetch PM2 status:", err);
    return statusMap;
  }
}

createServer(async (req, res) => {
  if (req.url === "/agent-status.json") {
    const status = await getAgentStatus();
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
  console.log(`✅ Dev server with HTTP heartbeat checks running at http://localhost:${PORT}`);
});
