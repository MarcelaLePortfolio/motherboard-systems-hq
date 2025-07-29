import http from "http";
import { createAgentRuntime } from "../../mirror/agent.js";

console.log("✅ Effie heartbeat script executing...");
export const effie = { name: "Effie", port: 3013 };
createAgentRuntime(effie);

http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ status: "online", agent: "Effie" }));
}).listen(effie.port, () => {
  console.log(`🌐 Effie heartbeat listening on port ${effie.port}`);
});
