#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

NODE_BIN="${NODE_BIN:-node}"

# This smoke test is self-contained: it spins a tiny Express app using the middleware,
# validates OFF/SHADOW/ENFORCE behavior, and exits cleanly.

TMP_DIR="$(mktemp -d)"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

cat > "$TMP_DIR/phase44_smoke_app.mjs" <<'JS'
import express from "express";
import http from "http";

import { createMutationEnforcementMiddleware } from "../server/enforcement/phase44_mutation_enforcer.mjs";

function must(cond, msg) {
  if (!cond) {
    console.error("ASSERT_FAIL:", msg);
    process.exit(2);
  }
}

async function httpReq({ port, method, path }) {
  return new Promise((resolve, reject) => {
    const req = http.request(
      { hostname: "127.0.0.1", port, method, path },
      (res) => {
        let data = "";
        res.setEncoding("utf8");
        res.on("data", (c) => (data += c));
        res.on("end", () => resolve({ status: res.statusCode, body: data }));
      }
    );
    req.on("error", reject);
    req.end();
  });
}

const allowlist = [
  { method: "POST", path: "/api/allowed" },
  { method: "DELETE", path: "/api/items/:id" },
];

async function runMode(mode) {
  const app = express();

  // Middleware under test
  app.use(
    createMutationEnforcementMiddleware({
      mode,
      allowlist,
      logger: {
        warn: () => {},
        error: () => {},
      },
    })
  );

  // Minimal routes
  app.post("/api/allowed", (_req, res) => res.status(200).json({ ok: true, route: "allowed" }));
  app.post("/api/blocked", (_req, res) => res.status(200).json({ ok: true, route: "blocked" }));
  app.delete("/api/items/:id", (req, res) => res.status(200).json({ ok: true, id: req.params.id }));
  app.get("/api/read", (_req, res) => res.status(200).json({ ok: true, route: "read" }));

  const server = app.listen(0, "127.0.0.1");
  await new Promise((r) => server.once("listening", r));
  const port = server.address().port;

  // Read route always allowed
  {
    const r = await httpReq({ port, method: "GET", path: "/api/read" });
    must(r.status === 200, `${mode}: GET should be 200`);
  }

  // Allowlisted mutation allowed in all modes
  {
    const r = await httpReq({ port, method: "POST", path: "/api/allowed" });
    must(r.status === 200, `${mode}: allowlisted POST should be 200`);
  }

  // Non-allowlisted mutation:
  // - off: 200 (no-op)
  // - shadow: 200 (logged)
  // - enforce: 403
  {
    const r = await httpReq({ port, method: "POST", path: "/api/blocked" });
    if (mode === "enforce") {
      must(r.status === 403, `${mode}: blocked POST should be 403`);
      must(r.body.includes("E_MUTATION_NOT_ALLOWLISTED"), `${mode}: should include reason code`);
    } else {
      must(r.status === 200, `${mode}: blocked POST should be 200`);
    }
  }

  // Pattern allowlisted delete
  {
    const r = await httpReq({ port, method: "DELETE", path: "/api/items/abc123" });
    must(r.status === 200, `${mode}: allowlisted DELETE with param should be 200`);
  }

  await new Promise((r) => server.close(r));
}

await runMode("off");
await runMode("shadow");
await runMode("enforce");

console.log("OK: phase44 enforcement smoke passed");
JS

# Ensure express is installed in repo deps (expected). If not, fail clearly.
"$NODE_BIN" -e 'require("express"); console.log("OK: express present")' >/dev/null

# Run test from repo root so relative imports resolve.
cd "$ROOT"
"$NODE_BIN" "$TMP_DIR/phase44_smoke_app.mjs"
