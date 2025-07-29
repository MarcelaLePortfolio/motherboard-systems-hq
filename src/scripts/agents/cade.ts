import http from "http";
import { createAgentRuntime } from "../../mirror/agent.js";

console.log("✅ Cade heartbeat script executing...");
export const cade = { name: "Cade", port: 3012 };
createAgentRuntime(cade);

http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ status: "online", agent: "Cade" }));
}).listen(cade.port, () => {
  console.log(`🌐 Cade heartbeat listening on port ${cade.port}`);
});
