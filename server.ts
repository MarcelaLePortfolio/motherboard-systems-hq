<<<<<<< HEAD
// <0001fbC1> Serve real dashboard layout from public/
import express from "express";
import reflectionsRouter from "./scripts/api/reflections-router";
import statusRouter from "./scripts/api/status-router";
import tasksRouter from "./scripts/api/tasks-router";
import logsRouter from "./scripts/api/logs-router";

const app = express();
import statusRouter from "./scripts/api/status-router";
import tasksRouter from "./scripts/api/tasks-router";
import logsRouter from "./scripts/api/logs-router";
app.use("/status", statusRouter);
app.use("/tasks", tasksRouter);
app.use("/logs", logsRouter);

// ✅ Serve everything inside /public
import path from "path";
const publicDir = path.resolve("public");
app.use(express.static(publicDir));
console.log(`📂 Serving static files from ${publicDir}`);

// ✅ API routes first
app.use("/api/reflections", reflectionsRouter);
import statusRouter from "./scripts/api/status-router";
import tasksRouter from "./scripts/api/tasks-router";
import logsRouter from "./scripts/api/logs-router";
import matildaRouter from "./scripts/api/matilda-router";
app.use("/matilda", matildaRouter);

// ✅ Redirect /dashboard → /dashboard.html (actual file)
app.get("/dashboard", (_req, res) =>
  res.sendFile(path.join(publicDir, "dashboard.html"))
);

// ✅ Root → dashboard
app.get("/", (_req, res) => res.redirect("/dashboard"));

// ✅ 404 fallback
app.use((_req, res) => res.status(404).send("<h1>404 – Page not found</h1>"));

const PORT = process.env.PORT || 3001;
app.listen(PORT, () =>
  console.log(`🚀 Express server running at http://localhost:${PORT}`)
);
=======
import http from 'http';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const publicDir = path.join(__dirname, 'public');

const server = http.createServer((req, res) => {
  let filePath = path.join(publicDir, req.url === '/' ? 'dashboard.html' : req.url);

  const extname = path.extname(filePath).toLowerCase();
  const mimeTypes = {
    '.html': 'text/html',
    '.js': 'text/javascript',
    '.css': 'text/css',
    '.json': 'application/json',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.gif': 'image/gif',
    '.svg': 'image/svg+xml',
    '.ico': 'image/x-icon',
  };

  const contentType = mimeTypes[extname] || 'application/octet-stream';

  fs.readFile(filePath, (err, content) => {
    if (err) {
      if (err.code === 'ENOENT') {
        res.writeHead(404);
        res.end('404 - Not Found');
      } else {
        res.writeHead(500);
        res.end(`Server Error: ${err.code}`);
      }
    } else {
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(content);
    }
  });
});

const PORT = 3000;
server.listen(PORT, () => {
  console.log(`🌐 Dashboard running at http://localhost:${PORT}`);
});
>>>>>>> c4b1123 (✅ Mobile dashboard MVP: Agent Status, working Chatbot, cleaned layout)
