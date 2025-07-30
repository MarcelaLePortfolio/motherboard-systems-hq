import http from "http";

console.log("🚀 Launching Effie agent with heartbeat...");

const port = 3013;

// Keep process alive
setInterval(() => {}, 1000);

// Simple heartbeat server
http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ agent: "effie", status: "online" }));
}).listen(port, () => {
  console.log(`💚 Effie heartbeat listening on port ${port}`);
});
