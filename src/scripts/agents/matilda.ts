import http from "http";
import { createAgentRuntime } from "../../../mirror/agent.js";

export const matilda = { name: "Matilda", port: 3014 };

// Start runtime for dashboard PM2 check
createAgentRuntime(matilda);

// Serve heartbeat JSON
http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ status: "online", agent: "matilda", path: req.url }));
}).listen(matilda.port, () => {
  console.log(`🌐 Matilda heartbeat listening on port ${matilda.port}`);
});
