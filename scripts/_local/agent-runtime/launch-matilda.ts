import http from "http";
import path from "path";
import { createRequire } from "module";
import { stabilizeRuntime } from "../../../mirror/runtime/stabilization-layer";

stabilizeRuntime();

const require = createRequire(import.meta.url);

const { createAgentRuntime } = require("../../../mirror/agent");

// 🔒 HARD BYPASS: filesystem-resolved registry (avoids tsx module graph)
const registryPath = path.join(process.cwd(), "mirror/mesh/registry.ts");
const { registerAgent } = require(registryPath);

// agent module
const matildaModule = require(
  "../../../agents/matilda.ts/matilda.mjs"
);

const matilda =
  matildaModule.matilda ??
  matildaModule.default ??
  matildaModule;

registerAgent("matilda", matilda);

createAgentRuntime(matilda);

const PORT = process.env.MATILDA_PORT || 3001;

const server = http.createServer((req, res) => {
  if (req.url === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ status: "ok", agent: "matilda" }));
    return;
  }

  if (req.url === "/mesh") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ agent: "matilda", mesh: "active" }));
    return;
  }

  res.writeHead(200, { "Content-Type": "text/plain" });
  res.end("matilda mesh runtime active");
});

server.listen(PORT, () => {
  console.log(`[MESH] matilda bound on port ${PORT}`);
});
