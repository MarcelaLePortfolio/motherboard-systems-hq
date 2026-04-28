import http from "http";
import { stabilizeRuntime } from "../../../mirror/runtime/stabilization-layer";
import { createRequire } from "module";

stabilizeRuntime();

const require = createRequire(import.meta.url);

const { createAgentRuntime } = require("../../../mirror/agent");
const matildaModule = require("../../../agents/matilda.ts/matilda.mjs");

const matilda =
  matildaModule.matilda ??
  matildaModule.default ??
  matildaModule;

createAgentRuntime(matilda);

const PORT = process.env.MATILDA_PORT || 3001;

const server = http.createServer((req, res) => {
  if (req.url === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ status: "ok", agent: "matilda" }));
    return;
  }

  res.writeHead(200, { "Content-Type": "text/plain" });
  res.end("matilda runtime active");
});

server.listen(PORT, () => {
  console.log(`[MATILDA] HTTP runtime bound on port ${PORT}`);
});
