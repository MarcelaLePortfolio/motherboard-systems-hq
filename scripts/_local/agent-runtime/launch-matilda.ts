import http from "http";

console.log("🚀 Launching Matilda agent with heartbeat...");

const port = 3014;

// Keep process alive
setInterval(() => {}, 1000);

// Simple heartbeat server
http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ agent: "matilda", status: "online" }));
}).listen(port, () => {
  console.log(`💚 Matilda heartbeat listening on port ${port}`);
});
