import http from "http";
import { createAgentRuntime } from "../../mirror/agent.js";

console.log("✅ Matilda heartbeat script executing...");
export const matilda = { name: "Matilda", port: 3014 };
createAgentRuntime(matilda);

http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ status: "online", agent: "Matilda" }));
}).listen(matilda.port, () => {
  console.log(`🌐 Matilda heartbeat listening on port ${matilda.port}`);
});
