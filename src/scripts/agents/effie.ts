import http from "http";
import { createAgentRuntime } from "../../mirror/agent.js";

export const effie = { name: "Effie", port: 3013 };
createAgentRuntime(effie);

http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ status: "online", agent: "effie" }));
}).listen(effie.port, () => {
  console.log(`🌐 Effie heartbeat listening on port ${effie.port}`);
});
