// scripts/api/command.cjs – simple command logger for agent dispatch

const fs = require("fs");
const http = require("http");

const PORT = 3100;
const LOG_PATH = "./logs/command.log";

http
  .createServer((req, res) => {
    if (req.method === "POST" && req.url === "/api/command") {
      let body = "";
      req.on("data", chunk => (body += chunk));
      req.on("end", () => {
        try {
          const { command } = JSON.parse(body);
          const entry = `[${new Date().toISOString()}] ${command}\n`;
          fs.appendFileSync(LOG_PATH, entry);
          res.writeHead(200);
          res.end("Command received");
        } catch (e) {
          res.writeHead(400);
          res.end("Bad request");
        }
      });
    } else {
      res.writeHead(404);
      res.end("Not found");
    }
  })
  .listen(PORT, () => {
    console.log(`Command API running on http://localhost:${PORT}`);
  });
