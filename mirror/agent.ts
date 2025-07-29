/**
 * Mirror Agent stub with HTTP heartbeat
 */
import http from "http";

export function createAgentRuntime(agent: any) {
  const name = agent?.name || "Agent";
  console.log(`Mirror stub: Launching agent runtime for ${name}`);

  // Heartbeat log to keep process alive
  setInterval(() => {
    console.log(`✅ ${name} heartbeat...`);
  }, 10000);

  // Minimal HTTP server for dashboard checks
  const port = agent?.port || 0;
  if (port) {
    http.createServer((req, res) => {
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ status: "online", agent: name }));
    }).listen(port, () => {
      console.log(`🌐 ${name} stub server listening on port ${port}`);
    });
  }
}
