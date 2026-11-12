#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

node << 'NODE'
const fs = require("fs");
const path = require("path");

function assert(condition, message) {
  if (!condition) {
    console.error(`FAIL: ${message}`);
    process.exit(1);
  }
  console.log(`PASS: ${message}`);
}

const server = fs.readFileSync("server/index.ts", "utf8");
const html = fs.readFileSync("client/dist/index.html", "utf8");

const auth = server.indexOf("app.use(requireCloudflareAccess)");
const assets = server.indexOf('"/assets"');
const route = server.indexOf('app.get("/ui"');

assert(auth >= 0, "Cloudflare Access middleware registered");
assert(assets > auth, "React assets mounted after authentication");
assert(route > auth, "Dashboard route registered after authentication");

assert(
  server.includes('path.resolve(process.cwd(), "client/dist")'),
  "Dashboard resolves the React build directory"
);

assert(
  server.includes('res.sendFile(path.join(dashboardBuildPath, "index.html"))'),
  "Dashboard serves the React entrypoint"
);

assert(
  !server.includes("res.send(`"),
  "Dashboard does not serve the legacy inline HTML"
);

const references = [
  ...html.matchAll(/(?:src|href)="(\/assets\/[^"]+)"/g),
].map(match => match[1]);

assert(references.length > 0, "React entrypoint references built assets");

for (const reference of references) {
  const asset = path.join("client/dist", reference.slice(1));
  assert(fs.existsSync(asset), `Built asset exists: ${reference}`);
}

console.log("REACT DASHBOARD ROUTE CONTRACT PASSED");
NODE
