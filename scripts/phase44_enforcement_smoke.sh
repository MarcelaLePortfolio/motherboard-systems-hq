#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NODE_BIN="${NODE_BIN:-node}"

# Phase 44 smoke: dependency-free (no express). We unit-smoke the middleware
# by invoking it with mocked req/res/next across ENFORCEMENT_MODE variants.

"$NODE_BIN" --input-type=module <<'JS'
import { createMutationEnforcementMiddleware } from "./server/enforcement/phase44_mutation_enforcer.mjs";

function must(cond, msg) {
  if (!cond) {
    console.error("ASSERT_FAIL:", msg);
    process.exit(2);
  }
}

function makeRes() {
  return {
    _status: 200,
    _json: undefined,
    status(code) { this._status = code; return this; },
    json(obj) { this._json = obj; return this; },
  };
}

async function runOne(mode) {
  const allowlist = [
    { method: "POST", path: "/api/allowed" },
    { method: "DELETE", path: "/api/items/:id" },
  ];

  const mw = createMutationEnforcementMiddleware({
    mode,
    allowlist,
    logger: { warn() {}, error() {} },
  });

  const call = async ({ method, path }) => {
    const req = { method, path, url: path };
    const res = makeRes();
    let nextCalled = 0;
    const next = () => { nextCalled += 1; };

    await mw(req, res, next);
    return { res, nextCalled };
  };

  // Read route always allowed (non-mutation => next called)
  {
    const { res, nextCalled } = await call({ method: "GET", path: "/api/read" });
    must(nextCalled === 1, `${mode}: GET should call next`);
    must(res._json === undefined, `${mode}: GET should not write response`);
  }

  // Allowlisted mutation allowed in all modes
  {
    const { res, nextCalled } = await call({ method: "POST", path: "/api/allowed" });
    must(nextCalled === 1, `${mode}: allowlisted POST should call next`);
    must(res._json === undefined, `${mode}: allowlisted POST should not write response`);
  }

  // Non-allowlisted mutation:
  // - off: next
  // - shadow: next
  // - enforce: 403 with stable reason code
  {
    const { res, nextCalled } = await call({ method: "POST", path: "/api/blocked" });
    if (mode === "enforce") {
      must(nextCalled === 0, `${mode}: blocked POST should not call next`);
      must(res._status === 403, `${mode}: blocked POST should be 403`);
      must(!!res._json && res._json.reason_code === "E_MUTATION_NOT_ALLOWLISTED", `${mode}: reason_code mismatch`);
      must(res._json.enforcement_mode === "enforce", `${mode}: enforcement_mode mismatch`);
      must(res._json.method === "POST", `${mode}: method mismatch`);
      must(res._json.path === "/api/blocked", `${mode}: path mismatch`);
    } else {
      must(nextCalled === 1, `${mode}: blocked POST should call next`);
      must(res._json === undefined, `${mode}: blocked POST should not write response`);
    }
  }

  // Pattern allowlisted delete
  {
    const { res, nextCalled } = await call({ method: "DELETE", path: "/api/items/abc123" });
    must(nextCalled === 1, `${mode}: allowlisted DELETE w/ param should call next`);
    must(res._json === undefined, `${mode}: allowlisted DELETE should not write response`);
  }
}

await runOne("off");
await runOne("shadow");
await runOne("enforce");

console.log("OK: phase44 enforcement smoke passed");
JS
