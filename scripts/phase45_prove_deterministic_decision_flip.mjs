/**
 * Phase 45 proof: deterministic decision flip with resolvePolicyGrant integrated.
 *
 * Proves (best-effort):
 * 1) Legacy evaluator is deterministic on a chosen fixture
 * 2) Wrapped evaluator is deterministic on the same fixture
 * 3) If a grant allows and legacy denies, wrapped deterministically flips to allow
 *
 * This repo's evaluator call-shape may not be a single-arg object.
 * So we try several common call shapes and pick the first that works.
 */

import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import crypto from "node:crypto";

function stableStringify(x) {
  const seen = new WeakSet();
  return JSON.stringify(
    x,
    (k, v) => {
      if (v && typeof v === "object") {
        if (seen.has(v)) return "[Circular]";
        seen.add(v);
      }
      return v;
    },
    2
  );
}

function sha256(s) {
  return crypto.createHash("sha256").update(s).digest("hex");
}

function deepEqualJson(a, b) {
  return stableStringify(a) === stableStringify(b);
}

function pickFixture() {
  const root = process.cwd();
  const candidates = [];

  function walk(dir) {
    const ents = fs.readdirSync(dir, { withFileTypes: true });
    for (const e of ents) {
      const p = path.join(dir, e.name);
      if (e.isDirectory()) {
        if (e.name === "node_modules" || e.name === ".git" || e.name === "dist" || e.name === ".next") continue;
        walk(p);
      } else if (e.isFile() && e.name.toLowerCase().endsWith(".json")) {
        const n = p.toLowerCase();
        if (
          n.includes("policy") &&
          (n.includes("probe") || n.includes("example") || n.includes("fixture") || n.includes("scenario"))
        ) {
          candidates.push(p);
        }
      }
    }
  }

  walk(root);
  if (candidates.length > 0) return candidates.sort()[0];
  return null;
}

function loadJson(p) {
  return JSON.parse(fs.readFileSync(p, "utf8"));
}

function normalizeAllowed(result) {
  if (!result || typeof result !== "object") return null;
  if (typeof result.allowed === "boolean") return result.allowed;
  if (typeof result.decision === "string") {
    const d = result.decision.toLowerCase();
    if (["allow", "permit", "approved", "approve", "ok"].includes(d)) return true;
    if (["deny", "block", "blocked", "reject", "rejected", "no"].includes(d)) return false;
  }
  if (typeof result.action_tier === "string") {
    const t = result.action_tier.toUpperCase();
    if (t === "A") return true;
    if (t === "B" || t === "C") return false;
  }
  return null;
}

function isGrantAllow(grantResult) {
  if (!grantResult) return false;
  if (typeof grantResult.allow === "boolean") return grantResult.allow;
  if (typeof grantResult.allowed === "boolean") return grantResult.allowed;
  if (typeof grantResult.decision === "string") {
    const d = grantResult.decision.toLowerCase();
    if (["allow", "permit", "approved", "approve", "ok"].includes(d)) return true;
  }
  if (typeof grantResult.effect === "string") {
    const e = grantResult.effect.toLowerCase();
    if (e.includes("allow") || e.includes("override")) return true;
  }
  if (grantResult.applies === true && typeof grantResult.outcome === "string") {
    const o = grantResult.outcome.toLowerCase();
    if (o.includes("allow") || o.includes("override")) return true;
  }
  return false;
}

function pickEvalFn(mod, label) {
  const candidates = [mod?.evaluatePolicy, mod?.evaluate, mod?.default];
  for (const fn of candidates) {
    if (typeof fn === "function") return fn;
  }
  const keys = Object.keys(mod || {});
  throw new TypeError(
    `${label} evaluator export is not a function. Expected one of: evaluatePolicy, evaluate, default. Got keys: ${keys.join(", ")}`
  );
}

function ensurePolicyFixture(fx) {
  // If fixture already has `policy`, keep it.
  if (fx && typeof fx === "object" && fx.policy && typeof fx.policy === "object") return fx;

  // Otherwise wrap it into a minimal envelope that satisfies `{ policy }` destructuring.
  return {
    policy: {
      // minimal safe defaults; repo-specific evaluator may ignore/override
      version: "phase45",
      rules: [],
    },
    input: fx,
  };
}

async function callEvalBestEffort(fn, fx) {
  const f = ensurePolicyFixture(fx);

  const attempts = [
    { name: "one-arg(envelope)", args: [f] },
    { name: "two-arg({}, envelope)", args: [{}, f] },
    { name: "two-arg(envelope, envelope)", args: [f, f] },
    { name: "two-arg({}, {policy})", args: [{}, { policy: f.policy, input: f.input }] },
    { name: "three-arg({}, {}, envelope)", args: [{}, {}, f] },
  ];

  let lastErr = null;
  for (const a of attempts) {
    try {
      return await fn(...a.args);
    } catch (e) {
      lastErr = e;
      // keep trying
    }
  }
  const msg =
    "Could not call evaluator with any known call-shape.\n" +
    "Tried:\n" +
    attempts.map((x) => `- ${x.name}`).join("\n") +
    "\n\nLast error:\n" +
    String(lastErr?.stack || lastErr);
  throw new Error(msg);
}

async function main() {
  const fixturePath = pickFixture();
  const rawFixture = fixturePath
    ? loadJson(fixturePath)
    : {
        // minimal synthesized input; may not trigger grants, but proves determinism
        policy: { version: "phase45", rules: [] },
        input: { action: "demo.action", actor: "phase45.proof", payload: { hello: "world" } },
      };

  const legacyMod = await import(path.join(process.cwd(), "server/policy/evaluate.legacy.mjs"));
  const wrappedMod = await import(path.join(process.cwd(), "server/policy/evaluate.mjs"));
  const grantsMod = await import(path.join(process.cwd(), "server/policy/resolvePolicyGrant.mjs"));

  const legacyEval = pickEvalFn(legacyMod, "Legacy");
  const wrappedEval = pickEvalFn(wrappedMod, "Wrapped");

  if (typeof grantsMod?.resolvePolicyGrant !== "function") {
    throw new TypeError("resolvePolicyGrant export is not a function from server/policy/resolvePolicyGrant.mjs");
  }
  const { resolvePolicyGrant } = grantsMod;

  const legacy1 = await callEvalBestEffort(legacyEval, rawFixture);
  const legacy2 = await callEvalBestEffort(legacyEval, rawFixture);
  if (!deepEqualJson(legacy1, legacy2)) {
    console.error("FAIL: legacy evaluator is not deterministic on chosen fixture");
    console.error("legacy1_sha=", sha256(stableStringify(legacy1)));
    console.error("legacy2_sha=", sha256(stableStringify(legacy2)));
    process.exit(2);
  }

  const wrap1 = await callEvalBestEffort(wrappedEval, rawFixture);
  const wrap2 = await callEvalBestEffort(wrappedEval, rawFixture);
  if (!deepEqualJson(wrap1, wrap2)) {
    console.error("FAIL: wrapped evaluator is not deterministic on chosen fixture");
    console.error("wrap1_sha=", sha256(stableStringify(wrap1)));
    console.error("wrap2_sha=", sha256(stableStringify(wrap2)));
    process.exit(3);
  }

  // Best-effort grant input: pass the same envelope used for eval.
  const grantInput = ensurePolicyFixture(rawFixture);
  const grant = await resolvePolicyGrant({ ...grantInput, _phase45_probe: true });
  const grantAllows = isGrantAllow(grant);

  const legacyAllowed = normalizeAllowed(legacy1);
  const wrapAllowed = normalizeAllowed(wrap1);

  console.log("fixture=", fixturePath || "(synthesized)");
  console.log("legacy_allowed=", legacyAllowed);
  console.log("wrapped_allowed=", wrapAllowed);
  console.log("grant_allows=", grantAllows);

  if (legacyAllowed === false && grantAllows && wrapAllowed === true) {
    console.log("OK: deterministic decision flip proven (deny -> allow via grant)");
    process.exit(0);
  }

  console.error("FAIL: could not prove deny->allow flip with current fixture/grant semantics.");
  console.error("ACTION: add/adjust a policy probe fixture JSON that is blocked by default but becomes allowed when a grant applies.");
  process.exit(4);
}

main().catch((e) => {
  console.error("ERROR:", e?.stack || String(e));
  process.exit(1);
});
