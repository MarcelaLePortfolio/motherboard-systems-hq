 
const http = require("http");
const fs = require("fs");
const path = require("path");

const PORT = 3000;
const PUBLIC_DIR = path.join(__dirname, "../public");
const LOG_PATH = path.join(__dirname, "../ops-stream.log");

http
  .createServer((req, res) => {
    const { method, url } = req;

    if (method === "POST" && url === "/api/command") {
      let body = "";
      req.on("data", chunk => (body += chunk));
      req.on("end", () => {
        try {
          const { command } = JSON.parse(body);
          const entry = `[${new Date().toISOString()}] ${command}
`;
          fs.appendFileSync(LOG_PATH, entry);
          res.writeHead(200);
          res.end("Command received");
        } catch {
          res.writeHead(400);
          res.end("Bad request");
        }
      });
      return;
    }

    const filePath = path.join(PUBLIC_DIR, url === "/" ? "dashboard.html" : url);
    fs.readFile(filePath, (err, data) => {
      if (err) {
        res.writeHead(404);
        res.end("Not found");
      } else {
        res.writeHead(200);
        res.end(data);
      }
    });
  })
  .listen(PORT, () => {
    console.log(`✅ UI + Command server running at http://localhost:${PORT}`);
  });
