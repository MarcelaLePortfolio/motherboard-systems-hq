import http from "http";

console.log("�� Launching Cade agent with heartbeat...");

const port = 3012;

// Keep process alive
setInterval(() => {}, 1000);

// Simple heartbeat server
http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ agent: "cade", status: "online" }));
}).listen(port, () => {
  console.log(`💚 Cade heartbeat listening on port ${port}`);
});
